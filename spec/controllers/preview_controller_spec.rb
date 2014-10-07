require "spec_helper"

describe PreviewController do
  let(:item_ids) { ["10.1371/journal.pone.0010031"] }
  let(:cart) { Cart.new(item_ids) }

  before do
    stub_request(:get, /api.crossref.org\/works/).
      to_return(File.open("spec/fixtures/api_crossref_single_doi.raw"))
    allow_any_instance_of(Cart).to receive(:items).and_return(cart.items)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "assigns results variables from Cart" do
      get :index
      expect(assigns(:results)).to match_array cart.items.values
    end
  end
end
