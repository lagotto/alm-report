class SearchCrossref
  def initialize(query, opts = {})
    @query = query[:everything]
  end

  def run
    response = conn.get "/works", {
      query: @query,
    }

    results = response.body["message"]["items"]
    total_results = response.body["message"]["total-results"]

    return results, total_results
  end

  def conn
    @conn ||= Faraday.new(url: "http://api.crossref.org") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
    end
  end
end
