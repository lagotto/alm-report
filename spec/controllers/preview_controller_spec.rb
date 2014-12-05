require "spec_helper"

describe PreviewController do
  let(:cart) { Cart.new(item_ids) }

  before do
    stub_request(:get, /api.crossref.org\/works/).
      to_return(File.open("spec/fixtures/api_crossref_single_doi.raw"))
    allow_any_instance_of(Cart).to receive(:items).and_return(cart.items)
  end

  describe "GET index" do
    context "single result" do
      let(:item_ids) { ["10.1371/journal.pone.0010031"] }


      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end

      it "assigns results variables from Cart" do
        get :index
        expect(assigns(:results)).to match_array cart.items.values
      end
    end

    context "many results" do
      let(:item_ids) { 200.times.map { |i| "10.1371/journal.pone.#{i}" }}

      it "paginates results" do
        get :index
        expect(assigns(:results).size).to eq(ENV["PER_PAGE"].to_i)

        get :index, current_page: 2
        expect(assigns(:results).size).to eq(ENV["PER_PAGE"].to_i)
      end
    end
  end
end
