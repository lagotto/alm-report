require "rails_helper"

describe "facets", type: :feature, vcr: true do
  it "selects and deselects facets", js: true do
    visit "/"

    fill_in "everything", with: "cancer"
    click_button "Search"

    expect(page).to have_content "cancer"

    first_facet = first(".facets li a")
    first_facet_text = first_facet.text

    second_facet = all(".facets li a")[1]
    second_facet_text = second_facet.text

    # Select first facet
    first_facet.click

    expect(page).to have_content first_facet_text
    expect(page).not_to have_content second_facet_text

    # Deselect first facet
    first(".facets li a").click

    expect(page).to have_content first_facet_text
    expect(page).to have_content second_facet_text

    # Select first facet again
    first(".facets li a").click

    third_facet = all(".facets li a")[1]
    third_facet_text = third_facet.text

    fourth_facet = all(".facets li a")[2]
    fourth_facet_text = fourth_facet.text

    # Select another facet from a different category
    third_facet.click

    # Generalize "plos one (123)" to "plos one ", because match counts change
    expect(page).to have_content first_facet_text.gsub(/\(.*\)/, '')
    expect(page).to have_content third_facet_text

    expect(page).not_to have_content second_facet_text
    expect(page).not_to have_content fourth_facet_text.gsub(/\(.*\)/, '')

    first(".work-info").find("input.check-save-work").click
    expect(page).to have_button("Preview List (1)")

    click_button "Preview List (1)"
    click_button "Create Report"

    expect(page).to have_content("Metrics Data")
  end
end

