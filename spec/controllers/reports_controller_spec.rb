require "spec_helper"

describe ReportsController do
  describe "GET generate" do
    it "redirects to home for session without dois" do
      @cart = Cart.new
      get :generate
      response.should redirect_to(controller: "home", action: "advanced")
    end
  end
end
