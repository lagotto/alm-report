require_relative '../solr_request'

class SolrQueryBuilder
  attr_reader :page_block, :query

  def initialize(params, fl = nil)
    @params = params.dup
    @sort = @params[:sort]

    @fl = fl || SolrRequest::FL
    @page_block = build_page_block
    @query = {}
  end

  def fl
    "fl=#{@fl}"
  end

  # Returns the portion of the solr URL with the q parameter, specifying
  # the search. Note that the results of this method *must* be URL-escaped
  # before use.
  def build
    clean_params
    build_filter_journals
    build_affiliate_param

    @query[:q] = @params.sort_by { |k, _| k }.select do |k, _|
      SolrRequest::QUERY_PARAMS.include?(k.to_sym)
    end.map do |k, v|
      unless %w(affiliate publication_date).include?(k.to_s) # Pre-formatted
        v = quote_if_spaces(v)
      end
      "#{k}:#{v}"
    end.join(" AND ")

    Rails.logger.info("Solr query: #{@query}")
    @query
  end

  # Returns the portion of Solr URL with the query parameter & journal filter
  def build_advanced
    build_filter_journals

    if @params.has_key?(:unformattedQueryId)
      @query[:q] = @params[:unformattedQueryId].strip
    end
    @query
  end

  # Adds leading & trailing double-quotes to string if it contains whitespace.
  def quote_if_spaces(s)
    if /\s/.match(s)
      s = "\"#{s}\""
    end
    s
  end

  # The search page uses two form fields, author_country and institution, that
  # are both implemented by mapping onto the same field in the solr schema:
  # affiliate. This method handles building the affiliate param based on the
  # other two (whether or not they are present). It will also delete the two
  # "virtual" params as a side-effect.

  def build_affiliate_param
    parts = [@params[:author_country], @params[:institution]]
    parts = parts.compact.map do |part|
      quote_if_spaces(part)
    end
    if parts.present?
      affiliate = parts.join(" AND ")
      if parts.size > 1
        @params[:affiliate] = "(#{affiliate})"
      else
        @params[:affiliate] = affiliate
      end
    end
  end

  # Returns the fragment of the URL having to do with paging; specifically,
  # the rows and start parameters.  These can be passed in directly to the
  # constructor, or calculated based on the current_page param, if it's present.
  def build_page_block
    rows = @params[:rows]
    page_size = rows.nil? ? APP_CONFIG["results_per_page"] : rows
    result = "rows=#{page_size}"
    start = @params[:start]
    if start.nil?
      page = @params[:current_page]
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
    "&#{SolrRequest::FILTER}&#{fl}&wt=json&facet=false&#{@page_block}"
  end

  def sort
    if SolrRequest::SORTS.values.include? @sort
      "&sort=#{URI::encode(@sort)}"
    end
  end

  def url
    # :unformattedQueryId comes from advanced search
    if @params.has_key?(:unformattedQueryId)
      build_advanced
    else
      build
    end
    "#{APP_CONFIG["solr_url"]}?#{query_param}#{common_params}#{sort}&hl=false"
  end

  private

  def build_filter_journals
    if @params.has_key?(:filterJournals)
      @query[:fq] = @params[:filterJournals].map do |filter_journal|
        "cross_published_journal_key:#{filter_journal}"
      end.join(" OR ")
    end
  end

  def query_param
    unless @query[:q].present?
      @query[:q] = "*:*"
    end
    @query.to_param
  end

  def clean_params
    # Strip out empty and only keep whitelisted params
    @params.delete_if do |k, v|
      v.blank? || !SolrRequest::WHITELIST.include?(k.to_sym)
    end

    # Strip out the placeholder "all journals" journal value.
    @params.delete_if do |k, v|
      [k.to_s, v] == ["filterJournals", [SolrRequest::ALL_JOURNALS]]
    end
  end
end
