require 'rails_helper'

describe HomeController do
  describe "GET update_session", vcr: true do
    let(:work_ids) {
      [
        "10.1371/journal.pone.0113157",
        "10.1371/journal.pone.0114307",
        "10.1371/journal.pone.0114162"
      ]
    }

    let(:dois) {
      [
        "10.1371/journal.pone.0113157",
        "10.1371/journal.pone.0114307",
        "10.1371/journal.pone.0114162"
      ]
    }

    it "handles params" do
      post :update_session, { "work_ids" => work_ids, "mode" => "ADD" }
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
      post :update_session, { "work_ids" => work_ids, "mode" => "REMOVE" }
      body = JSON.parse(response.body)
      expect(body).to eq("status" => "success", "delta" => -3)
      session[:dois].should eq([])
    end
  end

  describe "parse_work_keys" do
    let(:work_ids) { ["10.1371/journal.pone.0010031|1410868245",
                         "10.1371/journal.pmed.0008763|1410868258"] }

    it "parses keys" do
      expect(subject.parse_work_keys(work_ids))
        .to eq("10.1371/journal.pone.0010031" => 1410868245,
               "10.1371/journal.pmed.0008763" => 1410868258)
    end

    it "parses nil" do
      expect(subject.parse_work_keys(nil)).to be_empty
    end

    it "respects limit" do
      expect(subject.parse_work_keys(work_ids, ENV["WORK_LIMIT"].to_i))
        .to be_empty
    end
  end

  describe "select_all_search_results" do
    it "adds all results to Cart", vcr: {
      cassette_name: "select_all_search_results/adds_all_results_to_Cart_" +
        ENV["SEARCH"]
    } do
      request.accept = "application/json"
      post :select_all_search_results, {
        everything: "biology"
      }

      response.status.should eq(200)

      get :get_work_count
      response.body.should eq(ENV["WORK_LIMIT"].to_s)
    end
  end
end
