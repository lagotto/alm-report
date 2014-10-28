require "spec_helper"

describe ApiController do
  describe "GET report_alm", vcr: true do
    it "gets data from the ALM API and CrossRef API" do
      @report = Report.new
      report_doi = ReportDoi.new
      report_doi.doi = "10.1371/journal.pcbi.1002727"
      report_doi.sort_order = 1
      @report.report_dois = [report_doi]
      @report.save

      get :report_alm, id: @report.id

      data = JSON.parse(response.body)
      data["data"].size.should eq 1
      data["data"][0]["journal"].should eq "PLoS Comput Biol"
    end
  end
end
