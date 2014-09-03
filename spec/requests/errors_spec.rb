require "spec_helper"

describe "errors" do

  it "routing errors" do
    get "/x"
    response.should render_template("rescues/routing_error")
    response.body.should include("Routing Error")
  end
end
