require "spec_helper"

if Search.plos?
  describe "filter by journal", type: :feature, vcr: true do
    it "considers journal filtering for select all", js: true do
      ## Before VCR, requests to foreign APIs can take more than the default 2s
      Capybara.default_wait_time = 20

      visit "/"
      fill_in "author", with: "Eisen"
      select "PLOS ONE", from: "filterJournals_"
      click_button "Search"
      page.should have_content "journals: PLOS ONE"
      page.should have_content "1 - 25 of 38 results"
      page.should have_content "for author: Eisen"
      expect(page).to have_button("Preview List (0)", disabled: true)
      find(".select-all-articles-link", text: "select all").click
      click_link "Select the remaining 13 articles"
      wait_for_ajax
      expect(page).to have_button("Preview List (38)")
    end
  end
end
