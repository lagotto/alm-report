require 'spec_helper'

describe SearchController do
  describe 'GET index' do
    it 'renders the add_articles template' do
      stub_request(
        :get,
        "http://api.crossref.org/works?offset=0&rows=25&query=cancer"
      ).to_return(File.open('spec/fixtures/api_crossref_cancer.raw'))

      stub_request(
        :get,
        "http://api.plos.org/search?facet=false&fl=id,pmid,publication_date," \
        "received_date,accepted_date,title,cross_published_journal_name," \
        "author_display,editor_display,article_type,affiliate,subject," \
        "financial_disclosure&fq%5B%5D=doc_type:full&" \
        "fq%5B%5D=!article_type_facet:%22Issue%20Image%22" \
        "&hl=false&q=everything:cancer&rows=25&wt=json"

      ).to_return(File.open('spec/fixtures/api_plos_cancer_search.raw'))
      get :"index", {
        utf8: "✓",
        everything: "cancer",
        author: "",
        author_country: "",
        institution: "",
        publication_days_ago: -1,
        datepicker1: "",
        datepicker2: "",
        subject: "",
        cross_published_journal_name: "All Journals",
        financial_disclosure: "",
        commit: "Search",
        x: "Y"
      }
      expect(response).to render_template('index')
    end
  end

  # PLOS specific spec, because there's no advanced search for CrossRef
  if Search.plos?
    describe "GET add_articles from advanced search" do
      it "renders the add_articles template" do
        url = "http://api.plos.org/search?facet=false&fl=id,pmid," \
          "publication_date,received_date,accepted_date,title," \
          "cross_published_journal_name,author_display,editor_display," \
          "article_type,affiliate,subject,financial_disclosure&" \
          "fq%5B%5D=cross_published_journal_key:PLoSCompBiol&" \
          "fq%5B%5D=doc_type:full&" \
          "fq%5B%5D=!article_type_facet:%22Issue%20Image%22&hl=false" \
          "&q=everything:biology&rows=25&wt=json"
        stub_request(:get, url).
          to_return(File.open('spec/fixtures/api_plos_biology_advanced.raw'))

        get :"index", {
          queryFieldId: "everything",
          queryTermId: "",
          startDateAsStringId: "",
          endDateAsStringId: "",
          unformattedQueryId: "everything:biology",
          commit: "Search",
          journalOpt: "some",
          filterJournals: ["PLoSCompBiol"],
          utf8: "✓"
        }

        expect(response).to render_template('index')
      end
    end
  end

end
