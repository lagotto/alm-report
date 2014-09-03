require 'spec_helper'

describe "errors", :type => :routing do
  it "should catch routing errors" do
    expect(:get => "/x").to route_to(
      :controller => "application",
      :action => "routing_error",
      :path => "x"
    )
  end
end
