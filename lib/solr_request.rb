require "date"
require "net/http"
require "open-uri"
require "json"
require_relative "solr/solr_query_builder"
require_relative "performance"

# Exception class thrown when the solr server returns a 50x response.
class SolrError < StandardError
end

# Interface to solr search for PLOS articles.  A thin wrapper around the solr http API.
#
# TODO: consider renaming this class.  Originally I thought there would also be a SolrResponse,
# but that was not necessary.
class SolrRequest
  include Performance
  SOLR_TIMESTAMP_FORMAT = "%Y-%m-%dT%H:%M:%SZ"

  FILTER = "fq=doc_type:full&fq=!article_type_facet:#{URI::encode("\"Issue Image\"")}"

  # The fields we want solr to return for each article by default.
  FL = "id,pmid,publication_date,received_date,accepted_date,title," \
      "cross_published_journal_name,author_display,editor_display,article_type,affiliate,subject," \
      "financial_disclosure"

  FL_METRIC_DATA = "id,alm_scopusCiteCount,alm_mendeleyCount,counter_total_all," \
      "alm_pmc_usage_total_all"

  FL_VALIDATE_ID = "id"

  ALL_JOURNALS = "All Journals"

  SORTS = {
    "Relevance" => "",
    "Date, newest first" => "publication_date desc",
    "Date, oldest first" => "publication_date asc",
    "Most views, last 30 days" => "counter_total_month desc",
    "Most views, all time" => "counter_total_all desc",
    "Most cited, all time" => "alm_scopusCiteCount desc",
    "Most bookmarked" => "sum(alm_citeulikeCount, alm_mendeleyCount) desc",
    "Most shared in social media" => "sum(alm_twitterCount, alm_facebookCount) desc",
    "Most tweeted" => "alm_twitterCount desc",
  }

  WHITELIST = [
    :everything, :author, :author_country, :institution, :publication_days_ago,
    :datepicker1, :datepicker2, :subject, :cross_published_journal_name,
    :financial_disclosure, :title, :publication_date
  ]

  # Creates a solr request.  The query (q param in the solr request) will be based on
  # the values of the params passed in, so these should all be valid entries in the PLOS schema.
  # If the fl argument is non-nil, it will specify what result fields to return from
  # solr; otherwise all fields that we are interested in will be returned.
  def initialize(params, fl=nil)
    @params = params
    @fl = fl
  end

  def self.send_query(url)
    start_time = Time.now
    resp = Net::HTTP.get_response(URI.parse(url))

    end_time = Time.now
    Rails.logger.debug "SOLR Request took #{end_time - start_time} seconds\n#{url}"

    if resp.code != "200"
      raise SolrError, "Server returned #{resp.code}: " + resp.body
    end
    return JSON.parse(resp.body)
  end

  # Returns a list of JSON entities for article results given a json response from solr.
  def self.parse_docs(json)
    docs = json["response"]["docs"]
    docs.map do |doc|
      doc = fix_data(doc)
      SearchResult.new(doc, :plos)
    end
  end

  # Performs a single solr search, based on the parameters set on this object.
  # Returns a tuple of the documents retrieved, and the total number of results.
  def query
    url = query_builder.url
    json = SolrRequest.send_query(url)
    docs = SolrRequest.parse_docs(json)
    return docs, json["response"]["numFound"]
  end

  # The goal is to mimic advanced search filter on the PLOS (journal) side
  # 1. use fq (filter query) with cross_published_journal_key field
  # 2. display the journal names that are tied to the
  #    cross_published_journal_key field on the front end
  def self.get_journal_name_key
    APP_CONFIG["journals"].values
  end

  # Logic for creating a limit on the publication_date for a query.  All params are strings.
  # Legal values for days_ago are "-1", "0", or a positive integer.  If -1, the method
  # returns (nil, nil) (no date range specified).  If 0, the values of start_date and end_date
  # are used to construct the returned range.  If positive, the range extends from
  # (today - days_ago) to today.  start_date and end_date, if present, should be strings in the
  # format %m-%d-%Y.
  def self.parse_date_range(days_ago, start_date, end_date)
    days_ago = days_ago.to_i
    end_time = Time.new
    if days_ago == -1  # All time; default.  Nothing to do.
      return nil, nil

    elsif days_ago == 0  # Custom date range
      start_time = Date.strptime(start_date, "%m-%d-%Y")
      end_time = DateTime.strptime(end_date + " 23:59:59", "%m-%d-%Y %H:%M:%S")

    else  # days_ago specifies start date; end date now
      start_time = end_time - (3600 * 24 * days_ago)
    end
    return start_time, end_time
  end

  # Returns a legal value constraining the publication_date solr field for the given start and
  # end DateTimes.  Returns nil if either of the arguments are nil.
  def self.build_date_range(start_date, end_date)
    if start_date.nil? || end_date.nil?
      return nil
    else
      return "[#{start_date.strftime(SOLR_TIMESTAMP_FORMAT)} " \
          "TO #{end_date.strftime(SOLR_TIMESTAMP_FORMAT)}]"
    end
  end

  # There are a handful of special cases where we want to display a "massaged"
  # version of what solr returns, instead of the direct value.  This method
  # takes care of all of those.
  def self.fix_data(doc)
    SolrRequest.fix_date(doc, "publication_date")
    SolrRequest.fix_date(doc, "received_date")
    SolrRequest.fix_date(doc, "accepted_date")

    # For articles cross-published in PLOS Collections, we want to display the
    # original journal name throughout the app.
    if doc["cross_published_journal_name"] && doc["cross_published_journal_name"].length > 1
      collections_index = doc["cross_published_journal_name"].index("PLOS Collections")
      if !collections_index.nil?
        new_index = collections_index == 0 ? 1 : 0
        doc["cross_published_journal_name"][0] = doc["cross_published_journal_name"][new_index]
      end
    end
    doc
  end

  # Substitutes a formatted value for a date field of the given name
  # in the solr data structure.
  def self.fix_date(doc, date_field_name)
    if doc[date_field_name]
      doc[date_field_name] = Date.strptime(doc[date_field_name], SOLR_TIMESTAMP_FORMAT)
    end
    doc
  end

  # helper function for retrieving data from solr
  def self.get_data_helper(report_dois, cache_postfix, fields_to_retrieve)
    # TODO should we return emtpy array or nil if report_dois is nil / empty?

    all_results = {}
    if (report_dois.first.kind_of? String)
      dois = report_dois.clone
    else
      dois = report_dois.map { |report_doi| report_doi.doi }
    end

    # get solr data from cache
    if (!cache_postfix.nil?)
      dois.delete_if  do | doi |
        results = Rails.cache.read("#{doi}.#{cache_postfix}")
        if !results.nil?
          all_results[doi] = results
          true
        end
      end
    end

    while dois.length > 0 do
      subset_dois = dois.slice!(0, APP_CONFIG["solr_max_dois_per_request"])
      q = subset_dois.map { | doi | "id:\"#{doi}\"" }.join(" OR ")

      url = "#{APP_CONFIG["solr_url"]}?q=#{URI::encode(q)}&#{FILTER}&fl=#{fields_to_retrieve}" \
          "&wt=json&facet=false&rows=#{subset_dois.length}"

      json = SolrRequest.send_query(url)

      docs = json["response"]["docs"]
      docs.each do |doc|
        doc = fix_data(doc)
        all_results[doc["id"]] = doc

        # store solr data in cache
        if (!cache_postfix.nil?)
          Rails.cache.write("#{doc["id"]}.#{cache_postfix}", doc, :expires_in => 1.day)
        end
      end
    end

    return all_results
  end

  # Retrieves article related information from solr for a given list of DOIs.
  def self.get_data_for_articles(report_dois)
    measure(report_dois) do
      SolrRequest.get_data_helper(report_dois, "solr", FL)
    end
  end

  def self.validate_dois(report_dois)
    measure(report_dois) do
      SolrRequest.get_data_helper(report_dois, nil, FL_VALIDATE_ID)
    end
  end

  # Performs a batch query for articles based on the list of PubMed IDs passed in.
  # Returns a hash of PMID => solr doc, with only id, pmid, and publication_date defined
  # in the solr docs.
  def self.query_by_pmids(pmids)
    return unless pmids.present?
    q = pmids.map {|pmid| "pmid:\"#{pmid}\""}.join(" OR ")
    url = "#{APP_CONFIG["solr_url"]}?q=#{URI::encode(q)}&#{FILTER}" \
        "&fl=id,publication_date,pmid&wt=json&facet=false&rows=#{pmids.length}"
    json = SolrRequest.send_query(url)
    docs = json["response"]["docs"]
    results = {}
    docs.each do |doc|
      if doc["publication_date"]
        doc["publication_date"] = Date.strptime(doc["publication_date"], SOLR_TIMESTAMP_FORMAT)
      end
      results[doc["pmid"].to_i] = SearchResult.new(doc, :plos)
    end
    results
  end

  private

  def query_builder
    SolrQueryBuilder.new(@params, @fl)
  end
end
