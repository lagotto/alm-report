require "spec_helper"

describe "preview list from dois", :type => :feature do
  before :each do
    stub_request(:get, /api.crossref.org\/works/).
      to_return(File.open('spec/fixtures/api_crossref_single_doi.raw'))
  end

  it "loads the articles result page", js: true do
    visit "/"

    click_link "By DOI/PMID"

    fill_in "doi-pmid-1", with: "10.1037/0003-066x.59.1.29"

    click_button "Add to My List"

    expect(page).to have_content "How the Mind Hurts and Heals the Body"
  end
end
