require 'rails_helper'

describe SearchController, vcr: true do
  describe 'GET index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template("simple")
    end
  end

  describe "GET show" do
    it "renders the show template" do
      get :show, {
        utf8: "✓",
        everything: "cancer",
        author: "",
        author_country: "",
        institution: "",
        publication_days_ago: "",
        datepicker1: "",
        datepicker2: "",
        subject: "",
        filters: [""],
        financial_disclosure: "",
        commit: "Search",
        x: "Y"
      }
      expect(response).to render_template("show")
    end
  end

  # PLOS specific spec, because there's no advanced search for CrossRef
  if Search.plos?
    describe "GET /search/advanced" do
      it "renders the advanced template" do
        get :index, advanced: true
        expect(response).to render_template("advanced")
      end
    end

    describe "GET show from advanced search" do
      it "renders the show template" do
        get :show, {
          queryFieldId: "everything",
          queryTermId: "",
          startDateAsStringId: "",
          endDateAsStringId: "",
          unformattedQueryId: "everything:biology",
          commit: "Search",
          journalOpt: "some",
          filters: ["PLoSCompBiol"],
          utf8: "✓"
        }

        expect(response).to render_template("show")
      end
    end
  end

end
