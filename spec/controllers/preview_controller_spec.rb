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
      let(:item_ids) { ["10.1371/journal.pone.0108359",
        "10.1371/journal.pone.0113605",
        "10.1371/journal.pmed.0020124",
        "10.1371/journal.pone.0112430",
        "10.1371/journal.pcbi.1003892",
        "10.1371/journal.pmed.1001747",
        "10.1371/journal.pone.0110509",
        "10.1371/journal.pone.0016885",
        "10.1371/journal.pbio.1002005",
        "10.1371/journal.pmed.1000097",
        "10.1371/journal.pone.0024658",
        "10.1371/journal.pone.0112077",
        "10.1371/journal.pmed.1000100",
        "10.1371/journal.pone.0069805",
        "10.1371/journal.pbio.1001983",
        "10.1371/journal.pmed.1000316",
        "10.1371/journal.pmed.1001244",
        "10.1371/journal.pcbi.1003833",
        "10.1371/journal.pone.0111670",
        "10.1371/journal.pmed.0040297",
        "10.1371/journal.pgen.1004754",
        "10.1371/journal.pbio.1001995",
        "10.1371/journal.pbio.1001998",
        "10.1371/journal.pbio.1001993",
        "10.1371/journal.pbio.1001987",
        "10.1371/journal.pone.0107541",
        "10.1371/journal.pmed.1001755",
        "10.1371/journal.pbio.1001988",
        "10.1371/journal.pone.0111597",
        "10.1371/journal.pone.0103547",
        "10.1371/journal.pone.0108887",
        "10.1371/journal.pone.0088278",
        "10.1371/journal.ppat.1004437",
        "10.1371/journal.pbio.1001996",
        "10.1371/journal.pmed.0030442",
        "10.1371/journal.ppat.1004473",
        "10.1371/journal.pone.0035538",
        "10.1371/journal.pgen.1004761",
        "10.1371/journal.pgen.1004787",
        "10.1371/journal.pmed.1001751",
        "10.1371/journal.pmed.1001750",
        "10.1371/journal.pmed.1001744",
        "10.1371/journal.ppat.1004502",
        "10.1371/journal.pone.0039504",
        "10.1371/journal.pgen.1004764",
        "10.1371/journal.pgen.1004735",
        "10.1371/journal.pgen.1004798",
        "10.1371/journal.ppat.1004503",
        "10.1371/journal.pone.0018556",
        "10.1371/journal.ppat.1004479"
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
