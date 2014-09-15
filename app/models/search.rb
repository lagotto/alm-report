require 'pry'

class Search
  def initialize(query)
    @query = query[:everything]
    @conn = Faraday.new(url: "http://api.crossref.org") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
    end
  end

  def find
    response = @conn.get "/works", {
      query: @query,
    }

    results = response.body["message"]["items"]
    total_results = response.body["message"]["total-results"]

    return results, total_results
  end

  def self.plos?
    APP_CONFIG['search'] == 'plos'
  end

  def self.crossref?
    APP_CONFIG['search'] == 'crossref'
  end
end
