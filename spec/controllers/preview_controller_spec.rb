describe PreviewController, vcr: true do
  let(:cart) { Cart.new(item_ids) }

  before do
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
      let(:item_ids) { [ "10.1371/journal.pone.0113545",
        "10.1371/journal.pone.0113544",
        "10.1371/journal.pone.0113532",
        "10.1371/journal.pone.0113204",
        "10.1371/journal.pone.0112953",
        "10.1371/journal.pone.0112950",
        "10.1371/journal.pone.0112905",
        "10.1371/journal.pone.0112903",
        "10.1371/journal.pone.0112895",
        "10.1371/journal.pone.0112872",
        "10.1371/journal.pone.0112851",
        "10.1371/journal.pone.0112850",
        "10.1371/journal.pone.0112846",
        "10.1371/journal.pone.0112815",
        "10.1371/journal.pone.0112803",
        "10.1371/journal.pone.0112781",
        "10.1371/journal.pone.0112771",
        "10.1371/journal.pone.0112766",
        "10.1371/journal.pone.0112764",
        "10.1371/journal.pone.0112737",
        "10.1371/journal.pone.0112714",
        "10.1371/journal.pone.0112694",
        "10.1371/journal.pone.0112693",
        "10.1371/journal.pone.0112672",
        "10.1371/journal.pone.0112642",
        "10.1371/journal.pone.0112641",
        "10.1371/journal.pone.0112611",
        "10.1371/journal.pone.0112609",
        "10.1371/journal.pone.0112560",
        "10.1371/journal.pone.0112554",
        "10.1371/journal.pone.0112548",
        "10.1371/journal.pone.0112541",
        "10.1371/journal.pone.0112535",
        "10.1371/journal.pone.0112528",
        "10.1371/journal.pone.0112525",
        "10.1371/journal.pone.0112523",
        "10.1371/journal.pone.0112522",
        "10.1371/journal.pone.0112514",
        "10.1371/journal.pone.0112509",
        "10.1371/journal.pone.0112505",
        "10.1371/journal.pone.0112504",
        "10.1371/journal.pone.0112497",
        "10.1371/journal.pone.0112485",
        "10.1371/journal.pone.0112476",
        "10.1371/journal.pone.0112470",
        "10.1371/journal.pone.0112466",
        "10.1371/journal.pone.0112462",
        "10.1371/journal.pone.0112459",
        "10.1371/journal.pone.0112429",
        "10.1371/journal.pone.0112427",
        "10.1371/journal.pone.0112418",
        "10.1371/journal.pone.0112415",
        "10.1371/journal.pone.0112408",
        "10.1371/journal.pone.0112407",
        "10.1371/journal.pone.0112400",
        "10.1371/journal.pone.0112390",
        "10.1371/journal.pone.0112387",
        "10.1371/journal.pone.0112385",
        "10.1371/journal.pone.0112351",
        "10.1371/journal.pone.0112332"
      ] }

      it "paginates results" do
        get :index
        expect(assigns(:results).size).to eq(ENV["PER_PAGE"].to_i)

        get :index, current_page: 2
        expect(assigns(:results).size).to eq(ENV["PER_PAGE"].to_i)
      end
    end
  end
end
