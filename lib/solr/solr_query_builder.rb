require_relative '../solr_request'

class SolrQueryBuilder
  attr_reader :page_block

  def initialize(params, fl = nil)
    @params = params
    @fl = fl || SolrRequest::FL
    @page_block = build_page_block
    @query = {}
  end

  def fl
    "fl=#{@fl}"
  end


  # Returns the portion of the solr URL with the q parameter, specifying the search.
  # Note that the results of this method *must* be URL-escaped before use.
  def build
    clean_params
    build_affiliate_param

    @query[:q] = @params.sort_by{|k,v| k}.map do |k,v|
      unless %i(affiliate publication_date).include?(k) # Pre-formatted
        v = quote_if_spaces(v)
      end
      "#{k}:#{v}"
    end.join(' AND ')

    Rails.logger.debug("Solr query: #{query}")
    query
  end


  # Returns the portion of the solr URL with the query parameter and journal filter populated
  def build_advanced_query
    if @params.has_key?(:unformattedQueryId)
      @query[:q] = @params[:unformattedQueryId].strip
    end

    if @params.has_key?(:filterJournals)
      filter_journals = @params[:filterJournals]
      @query[:fq] = filter_journals.map do |filter_journal|
        "cross_published_journal_key:#{filter_journal}"
      end.join(' OR ')
    end
    @query
  end

    # Adds leading and trailing double-quotes to the string if it contains any whitespace.
  def quote_if_spaces(s)
    if /\s/.match(s)
      s = "\"#{s}\""
    end
    s
  end

  # The search page uses two form fields, author_country and institution, that are both
  # implemented by mapping onto the same field in the solr schema: affiliate. This method
  # handles building the affiliate param based on the other two (whether or not they are
  # present). It will also delete the two "virtual" params as a side-effect.
  def build_affiliate_param
    parts = [@params.delete(:author_country), @params.delete(:institution)]
    parts = parts.compact.map do |part|
      quote_if_spaces(part)
    end
    if parts.present?
      affiliate = parts.join(' AND ')
      if parts.size > 1
        @params[:affiliate] = "(#{affiliate})"
      else
        @params[:affiliate] = affiliate
      end
    end
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
      build
      url = "#{APP_CONFIG["solr_url"]}?q=#{URI.encode(query)}&#{common_params}"
    else
      # advanced search query
      build_advanced_query
      url = "#{APP_CONFIG["solr_url"]}?#{advanced_query}&#{common_params}"
    end
  end

  private

  def query
    if @query[:q].present?
      @query[:q]
    else
      # if the user hasn't entered in anything, search for everything
      '*:*'
    end
  end

  def advanced_query
    unless @query[:q].present?
      @query[:q] = '*:*'
    end
    @query.to_param
  end

  def clean_params
    # Strip out empty params.  Has to be done in a separate loop from the one below to
    # preserve the AND logic.
    @params.delete_if{|k, v| v.blank?}
    # Strip out the placeholder "all journals" journal value.
    @params.delete_if{|k,v| [k.to_s, v] == ['cross_published_journal_name', SolrRequest::ALL_JOURNALS]}
  end
end
