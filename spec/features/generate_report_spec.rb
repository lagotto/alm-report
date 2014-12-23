require 'rails_helper'

describe 'generate report', type: :feature, vcr: true do
  if Search.plos?
    it 'loads the visualization for a single article', js: true do
      visit '/'
      fill_in 'everything', with: 'cancer'
      click_button 'Search'
      expect(page).to have_content 'Cancer-Drug Associations: A Complex System'
      expect(page).to have_button('Preview List (0)', disabled: true)
      first('.article-info').find('input.check-save-article').click

      expect(page).to have_button('Preview List (1)')
      find_button('Preview List (1)').click
      expect(page).to have_content 'Cancer-Drug Associations: A Complex System'
      expect(page).not_to have_content 'Cancer as a Complex Phenotype: Pattern of Cancer Distribution'
      click_button 'Create Report'

      expect(page).to have_content('Metrics Data')
      expect(page).to have_content('Visualizations')

      click_link('Visualizations')

      expect(page).to have_css('.line.chart svg')

    end

    it 'loads the visualization for multiple articles', js: true do
      visit '/'
      fill_in 'everything', with: 'cancer'
      click_button 'Search'
      expect(page).to have_content 'Cancer-Drug Associations: A Complex System'
      expect(page).to have_button('Preview List (0)', disabled: true)

      first('.article-info').find('input.check-save-article').click
      expect(page).to have_button('Preview List (1)')
      all('.article-info')[5].find('input.check-save-article').click
      expect(page).to have_button('Preview List (2)')
      find_button('Preview List (2)').click
      expect(page).to have_content 'Cancer-Drug Associations: A Complex System'
      expect(page).to have_content 'A Comparative Analysis of Gene-Expression Data of Multiple Cancer Types'
      expect(page).not_to have_content 'Cancer as a Complex Phenotype: Pattern of Cancer Distribution'
      click_button 'Create Report'

      expect(page).to have_content('Metrics Data')
      expect(page).to have_content('Visualizations')
      click_link('Visualizations')

      expect(page).to have_css('.bubble.chart svg')
    end
  elsif Search.crossref?
    it "loads the visualization for a single article", js: true do
      visit "/"

      fill_in "everything",
        with: "A Future Vision for PLOS Computational Biology"

      click_button "Search"

      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).to have_button("Preview List (0)", disabled: true)
      first(".article-info").find("input.check-save-article").click

      expect(page).to have_button("Preview List (1)")
      find_button("Preview List (1)").click
      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).not_to have_content "What Do I Want from the Publisher of the Future?"
      click_button "Create Report"

      expect(page).to have_content("Metrics Data")
      expect(page).to have_content("Visualizations")
      click_link("Visualizations")

      expect(page).to have_css(".line.chart svg")
    end

    it "loads the visualization for a multiple articles", js: true do
      visit "/"

      fill_in "everything",
        with: "A Future Vision for PLOS Computational Biology"

      click_button "Search"

      first(".article-info").find("input.check-save-article").click
      expect(page).to have_button("Preview List (1)")
      click_link("3")

      all(".article-info")[2].find("input.check-save-article").click

      expect(page).to have_button("Preview List (2)")
      find_button("Preview List (2)").click
      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).to have_content "A Computational Model of Liver Iron Metabolism"
      expect(page).not_to have_content "Computational and Statistical Analysis of Protein Mass Spectrometry Data"
      click_button "Create Report"

      expect(page).to have_content("Metrics Data")
      expect(page).to have_content("Visualizations")
      click_link("Visualizations")

      expect(page).to have_css(".bubble.chart svg")
    end
  end
end

