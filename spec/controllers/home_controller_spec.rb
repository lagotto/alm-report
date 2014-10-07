require 'spec_helper'

describe HomeController do
  describe "GET update_session" do
    let(:article_ids) { ["10.1371/journal.pone.0010031",
                         "10.1371/journal.pmed.0010065",
                         "10.1371/journal.pone.0009584"] }

    let(:dois) { ["10.1371/journal.pone.0010031",
                  "10.1371/journal.pmed.0010065",
                  "10.1371/journal.pone.0009584" ] }

    before do
      stub_request(:get, /api.crossref.org\/works/).
        to_return(File.open('spec/fixtures/api_crossref_single_doi.raw'))
    end

    it "handles params" do
      post :update_session, { "article_ids" => article_ids, "mode" => "ADD" }
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => 3)
      session[:dois].should eq(dois)
    end

    it "handles empty params" do
      post :update_session, {}
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => 0)
      session[:dois].should eq([])
    end

    it "removes dois" do
      session[:dois] = dois
      post :update_session, { "article_ids" => article_ids, "mode" => "REMOVE" }
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => -3)
      session[:dois].should eq([])
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
end
