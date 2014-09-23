class SearchCrossref
  def initialize(query, opts = {})
    @query = query[:everything]
    @page = query[:current_page] || 1
    @rows = APP_CONFIG["results_per_page"]
  end

  def run
    response = SearchCrossref.get "/works", {
      query: @query,
      rows: @rows,
      offset: offset,
    }

    results = response.body["message"]["items"].map do |result|
      SearchResult.new(result)
    end

    total_results = response.body["message"]["total-results"]

    return results, total_results
  end

  def offset
    @rows * (@page.to_i - 1)
  end

  def self.get(url, params)
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
