require 'rails_helper'

describe "static pages", :type => :routing do
  it "routes about page" do
    expect(:get => "/about").to route_to(
      :controller => "static_pages",
      :action => "about"
    )
  end

  it "routes samples page" do
    expect(:get => "/samples").to route_to(
      :controller => "static_pages",
      :action => "samples"
    )
  end
end
