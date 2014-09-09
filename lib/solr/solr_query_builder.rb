require_relative '../solr_request'

class SolrQueryBuilder
  def initialize(params, fl = nil)
    @params = params
    @page_block = build_page_block
    @fl = fl || SolrRequest::FL
  end

  def fl
    "fl=#{@fl}"
  end

  # Returns the portion of the solr URL with the q parameter, specifying the search.
  # Note that the results of this method *must* be URL-escaped before use.
  def build
    # Strip out empty params.  Has to be done in a separate loop from the one below to
    # preserve the AND logic.
    solr_params = {}
    @params.keys.each do |key|
      value = @params[key].strip

      # Also take this opportunity to strip out the bogus "all journals" journal value.
      # It is implicit.
      if value.length > 0 &&
        (key.to_s != "cross_published_journal_name" || value != SolrRequest::ALL_JOURNALS)
          solr_params[key] = value
      end
    end

    solr_params = build_affiliate_param(solr_params)
    query = "q="

    # Sort the keys to ensure deterministic param order.  This is mainly for testing.
    keys = solr_params.keys.sort
    keys.each_with_index do |key, i|
      value = solr_params[key]
      if key != :affiliate && key != :publication_date  # params assumed to be pre-formatted
        value = quote_if_spaces(value)
      end
      query << "#{key}:#{value}"
      if keys.length > 1 && i < keys.length - 1
        query << " AND "
      end
    end

    # if the user hasn't entered in anything, search for everything
    if keys.empty?
      query << "*:*"
    end

    Rails.logger.debug("solr query: #{query}")
    query
  end


  # Returns the portion of the solr URL with the query parameter and journal filter populated
  def build_advanced_query
    solr_params = {}

    if @params.has_key?(:unformattedQueryId)
      solr_params[:q] = @params[:unformattedQueryId].strip
    else
      # this shouldn't happen but just in case
      solr_params[:q] = "*:*"
    end

    if @params.has_key?(:filterJournals)
      filter_journals = @params[:filterJournals]
      solr_params[:fq] = filter_journals.map { | filter_journal | "cross_published_journal_key:#{filter_journal}" }.join(" OR ")
    end

    return solr_params
  end

    # Adds leading and trailing double-quotes to the string if it contains any whitespace.
  def quote_if_spaces(s)
    if /\s/.match(s)
      s = "\"#{s}\""
    end
    return s
  end

  # The search page uses two form fields, author_country and institution, that are both
  # implemented by mapping onto the same field in the solr schema: affiliate.  This method
  # handles building the affiliate param based on the other two (whether or not they are
  # present).  It will also delete the two "virtual" params as a side-effect.
  def build_affiliate_param(solr_params)
    part1 = solr_params.delete(:author_country).to_s.strip
    part2 = solr_params.delete(:institution).to_s.strip
    if part1.length == 0 && part2.length == 0
      return solr_params
    end
    both = part1.length > 0 && part2.length > 0
    solr_params[:affiliate] = (both ? "(" : "") + quote_if_spaces(part1) + (both ? " AND " : "") \
        + quote_if_spaces(part2) + (both ? ")" : "")
    return solr_params
  end

  # Returns the fragment of the URL having to do with paging; specifically, the rows
  # and start parameters.  These can be passed in directly to the constructor, or calculated
  # based on the current_page param, if it is present.
  def build_page_block
    rows = @params.delete(:rows)
    page_size = rows.nil? ? APP_CONFIG["results_per_page"] : rows
    result = "rows=#{page_size}"
    start = @params.delete(:start)
    if start.nil?
      page = @params.delete(:current_page)
      page = page.nil? ? "1" : page
      page = page.to_i - 1
      if page > 0
        result << "&start=#{page * APP_CONFIG["results_per_page"] + 1}"
      end
    else  # start is specified
      result << "&start=#{start}"
    end
    result
  end

  def common_params
    "#{SolrRequest::FILTER}&#{fl}&wt=json&facet=false&#{@page_block}"
  end

  def url
    if !@params.has_key?(:unformattedQueryId)
      # execute home page search
      query = build
      url = "#{APP_CONFIG["solr_url"]}?#{URI::encode(query)}&#{common_params}"
    else
      # advanced search query
      solr_params = build_advanced_query
      url = "#{APP_CONFIG["solr_url"]}?#{solr_params.to_param}&#{common_params}"
    end
  end
end
