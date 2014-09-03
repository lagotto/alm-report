require 'spec_helper'

describe "static pages", :type => :routing do
  it "routes about page" do
    expect(:get => "/about").to route_to(
      :controller => "static_pages",
      :action => "about"
    )
  end

  it "routes privacy policy page" do
    expect(:get => "/privacy_policy").to route_to(
      :controller => "static_pages",
      :action => "privacy_policy"
    )
  end

  it "routes terms of use page" do
    expect(:get => "/terms_of_use").to route_to(
      :controller => "static_pages",
      :action => "terms_of_use"
    )
  end

  it "routes samples page" do
    expect(:get => "/samples").to route_to(
      :controller => "static_pages",
      :action => "samples"
    )
  end
end
