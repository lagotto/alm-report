class SearchCrossref
  def initialize(query, opts = {})
    @query = query[:everything]
    @filter = [query[:filter], "from-pub-date:2013-01-01"].compact.join(",")
    @page = query[:current_page] || 1
    @rows = APP_CONFIG["results_per_page"]
  end

  def run
    response = SearchCrossref.get "/works", request

    results = response.body["message"]["items"].map do |result|
      SearchResult.new(result)
    end

    total_results = response.body["message"]["total-results"]

    return results, total_results
  end

  def request
    request = {
      rows: @rows,
      offset: offset
    }
    request.merge!({ query: @query }) if @query.present?
    request.merge!({ filter: @filter }) if @filter.present?
    request
  end

  def offset
    @rows * (@page.to_i - 1)
  end

  def self.get(url, params = nil)
    conn.get(url, params)
  end

  def self.conn
    @conn ||= Faraday.new(url: "http://api.crossref.org") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
    end
  end
end
