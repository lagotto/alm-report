class SearchCrossref

  SORTS = {
    "Relevance" => "",
    "Date, newest first" => "published desc",
    "Date, oldest first" => "published asc",
  }

  def initialize(params, opts = {})
    @params = params
    @query = params[:everything]

    build_filters

    @filter = @filter.join(",")
    @page = params[:current_page] || 1
    @rows ||= params[:rows] || ENV["PER_PAGE"].to_i
    @sort, @order = params[:sort].try(:split)
  end

  def run
    response = SearchCrossref.get "/works", request

    results = response.body["message"]["items"].map do |result|
      SearchResult.new(result)
    end

    facets = parse_facets(response.body["message"]["facets"])
    total_results = response.body["message"]["total-results"]
    metadata = {}

    return {
      docs: results,
      facets: facets,
      found: total_results,
      metadata: metadata
    }
  end

  def request
    request = {
      rows: @rows,
      offset: offset,
      facet: "t"
    }

    request.merge!({ query: @query }) if @query.present?
    request.merge!({ filter: @filter }) if @filter.present?
    request.merge!({ sort: @sort, order: @order }) if @sort && @order
    request
  end

  def offset
    @rows * (@page.to_i - 1)
  end

  def build_filters
    publication_date = "from-pub-date:2011,until-pub-date:#{DateTime.now.year}"

    @filter = [
      @params[:filter],
      publication_date
    ].compact

    if @params[:facets]
      @filter += @params[:facets].map do |facet|
        if facet[:name] == "published"
          @filter.delete(publication_date)
          "from-pub-date:#{facet[:value]},until-pub-date:#{facet[:value]}"
        else
          "#{facet[:name]}:#{facet[:value]}"
        end
      end
    end

    if @params[:ids]
      @rows = @params[:ids].size
      @filter += @params[:ids].map{ |id| "doi:#{id}"}.join(",")
    end
  end

  def parse_facets(json)
    facets = Facet.new

    facets.add(%w[published publisher-name funder-name].map do |name|
      facet = {}
      facet[name] = Hash[*json[name]["values"].map do |k, v|
        [k, {count: v}]
      end.flatten]
      facet
    end)

    facets.each do |name, values|
      (@params[:facets] || []).each do |facet|
        if values.find{|key, value| key == facet[:value]}
          facets.select(name: name, value: facet[:value])
        end
      end
    end

    facets
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
