class ApiController < ApplicationController
  # API
  def report_alm
    @report = Report.find(params[:id])

    request = {
      api_key: APP_CONFIG["alm"]["api_key"],
      ids: @report.report_dois.map(&:doi).join(",")
    }

    conn = Faraday.new(url: APP_CONFIG["alm"]["url"]) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
    end

    alm = conn.get("/api/v5/articles", request).body

    alm["data"] = alm["data"].map do |result|
      result.update(journal: SearchResult.from_cache(result["doi"]).journal)
    end

    render json: alm
  end
end
