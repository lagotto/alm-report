require 'pry'

describe 'generate report', :type => :feature do
  before :each do
    WebMock.allow_net_connect!
  end

  after :each do
    WebMock.disable_net_connect!
  end

  it 'loads the articles result page', js: true do
    visit '/'
    binding.pry
    fill_in 'everything', with: 'biology'
    click_button 'Search'
    expect(page).to have_content 'A Future Vision for PLOS Computational Biology'
    expect(page).to have_button('Preview List (0)', disabled: true)
    first('.article-info.cf').find('input.check-save-article').click

    expect(page).to have_button('Preview List (1)')
    find_button('Preview List (1)').click
    expect(page).to have_content 'A Future Vision for PLOS Computational Biology'
    expect(page).not_to have_content 'Correction: A Biophysical Model of the Mitochondrial Respiratory System and Oxidative Phosphorylation'
    click_button 'Create Report'

    expect(page).to have_content('Metrics Data')
    expect(page).to have_content('Visualizations')
    click_link('Visualizations')

    expect(page).to have_css('#article_usage_div svg')
  end
end
