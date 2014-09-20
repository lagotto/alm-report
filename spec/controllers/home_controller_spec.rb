require 'spec_helper'

describe HomeController do
  describe 'GET index' do
    it 'renders the index template' do
      stub_request(
        :get,
        "http://api.plos.org/search?facet=true&facet.field=" \
        "cross_published_journal_key&facet.mincount=1&" \
        "fq%5B%5D=doc_type:full&" \
        "fq%5B%5D=!article_type_facet:%22Issue%20Image%22&q=*:*&rows=0&wt=json"
      ).to_return(
        File.open('spec/fixtures/solr_request_get_journal_name_key.raw')
      )
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET add_articles' do
    it 'renders the add_articles template' do
      stub_request(:get, "http://api.crossref.org/works?query=cancer").
        to_return(File.open('spec/fixtures/api_crossref_cancer.raw'))
      stub_request(
        :get,
        "http://api.plos.org/search?facet=false&fl=id,pmid,publication_date," \
        "received_date,accepted_date,title,cross_published_journal_name," \
        "author_display,editor_display,article_type,affiliate,subject," \
        "financial_disclosure&fq%5B%5D=doc_type:full&" \
        "fq%5B%5D=!article_type_facet:%22Issue%20Image%22" \
        "&hl=false&q=everything:cancer&rows=25&wt=json"

      ).to_return(File.open('spec/fixtures/api_plos_cancer_search.raw'))
      get :"add_articles", {
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
      expect(response).to render_template('add_articles')
    end
  end

  describe "GET update_session" do
    let(:article_ids) { ["10.1371/journal.pone.0010031|1270166400",
                         "10.1371/journal.pmed.0010065|1104192000",
                         "10.1371/journal.pone.0009584|1268092800"] }
    let(:dois) { { "10.1371/journal.pone.0010031" => 1270166400,
                   "10.1371/journal.pmed.0010065" => 1104192000,
                   "10.1371/journal.pone.0009584" => 1268092800 } }

    it "handles params" do
      post :update_session, { "article_ids" => article_ids, "mode" => "SAVE" }
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => 3)
      session[:dois].should eq(dois)
    end

    it "handles empty params" do
      post :update_session, {}
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => 0)
      session[:dois].should eq({})
    end

    it "removes dois" do
      session[:dois] = dois
      post :update_session, { "article_ids" => article_ids, "mode" => "REMOVE" }
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => -3)
      session[:dois].should eq({})
    end
  end

  describe "parse_article_keys" do
    let(:article_ids) { ["10.1371/journal.pone.0010031|1410868245",
                         "10.1371/journal.pmed.0008763|1410868258"] }

    it "parses keys" do
      expect(subject.parse_article_keys(article_ids))
        .to eq("10.1371/journal.pone.0010031" => 1410868245,
               "10.1371/journal.pmed.0008763" => 1410868258)
    end

    it "parses nil" do
      expect(subject.parse_article_keys(nil)).to be_empty
    end

    it "respects limit" do
      expect(subject.parse_article_keys(article_ids,
                                        APP_CONFIG["article_limit"]))
        .to be_empty
    end
  end

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

      get :"add_articles", {
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

      expect(response).to render_template('add_articles')
    end
  end

end
