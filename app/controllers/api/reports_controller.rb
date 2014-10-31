class Api::ReportsController < ApplicationController
  respond_to :json

  # API
  def show
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

    # Ember-friendly JSON formatting
    alm["id"] = @report.id
    result = {report: alm}
    result["items"] = alm.delete("data").map do |result|
      result["id"] = result["doi"]
      result.update(journal: SearchResult.from_cache(result["doi"]).journal)
    end

    render json: result
  end
end
