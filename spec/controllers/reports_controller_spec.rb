require "spec_helper"

describe ReportsController do
  describe "GET generate" do
    it "redirects to home for session without dois" do
      @cart = Cart.new
      get :generate
      expect(response).to redirect_to(search_advanced_path)
    end
  end

  describe "GET download_data" do
    if Search.plos?
      it "generates the correct CSV" do
        stub_request(:get, /api.plos.org\/search/).
          to_return(File.open('spec/fixtures/api_plos_biology_search.raw'))

        stub_request(:get, %r{/api/v3/articles.*(&info=history)?}).
          to_return(File.open('spec/fixtures/alm_api_journal.pcbi.1002727.raw'))

        stub_request(:get, %r{/api/v3/articles.*&info=event}).
          to_return(File.open('spec/fixtures/alm_api_journal.pcbi.102727.event.raw'))

        @report = Report.new
        report_doi = ReportDoi.new
        report_doi.doi = "10.1371/journal.pcbi.1002727"
        report_doi.sort_order = 1
        results = Search.find({everything: "test"})
        report_doi.solr = [results.first]
        alm = Alm.get_data_for_one_article([report_doi])
        report_doi.alm = alm[report_doi.doi]
        @report.report_dois = [report_doi]
        @report.save

        get :download_data, format: "csv", id: @report.id

        expect(response.body).to eq(
          File.open("spec/fixtures/csv_export.csv").read
        )
      end
    end
  end
end
