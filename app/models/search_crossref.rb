class SearchCrossref

  SORTS = {
    "Relevance" => "",
    "Date, newest first" => "published desc",
    "Date, oldest first" => "published asc",
  }

  def initialize(query, opts = {})
    @query = query[:everything]

    @filter = [
      query[:filter],
      "from-pub-date:2011",
      "until-pub-date:#{DateTime.now.year}"
    ].compact.join(",")

    if @query[:ids]
      @filter += "," + @query[:ids].map{ |id| "doi:#{id}"}.join(",")
    end

    @page = query[:current_page] || 1
    @rows = query[:rows] || ENV["PER_PAGE"].to_i
    @sort, @order = query[:sort].try(:split)
  end

  def run
    response = SearchCrossref.get "/works", request

    results = response.body["message"]["items"].map do |result|
      SearchResult.new(result)
    end

    total_results = response.body["message"]["total-results"]

    metadata = {}
    return results, total_results, metadata
  end

  def request
    request = {
      rows: @rows,
      offset: offset
    }
    request.merge!({ query: @query }) if @query.present?
    request.merge!({ filter: @filter }) if @filter.present?
    request.merge!({ sort: @sort, order: @order }) if @sort && @order
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
