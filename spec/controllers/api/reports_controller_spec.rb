require "rails_helper"

describe Api::ReportsController do
  describe "GET report_alm", vcr: true do
    it "gets data from the ALM API and search API" do
      @report = Report.new
      report_doi = ReportDoi.new
      report_doi.doi = "10.1371/journal.pcbi.1002727"
      report_doi.sort_order = 1
      @report.report_dois = [report_doi]
      @report.save

      get :show, id: @report.id

      data = JSON.parse(response.body)
      expect(data["report"]["items"].size).to eq 1

      expect(data["report"]["items"][0]["journal"].downcase).to eq \
        "plos computational biology"
    end
  end
end
