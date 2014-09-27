require 'spec_helper'

if Search.plos?
  describe 'generate report', :type => :feature do
    before :each do
      stub_request(:get,
        "http://api.plos.org/search?facet=true&facet.field=cross_published_journal_key&facet.mincount=1&fq%5B%5D=doc_type:full&fq%5B%5D=!article_type_facet:%22Issue%20Image%22&q=*:*&rows=0&wt=json"
      ).to_return(File.open('spec/fixtures/solr_request_get_journal_name_key.raw'))

      stub_request(:get,
        'http://api.plos.org/search?facet=false&fl=id,pmid,publication_date,received_date,accepted_date,title,cross_published_journal_name,author_display,editor_display,article_type,affiliate,subject,financial_disclosure&fq%5B%5D=doc_type:full&fq%5B%5D=!article_type_facet:%22Issue%20Image%22&hl=false&q=everything:cancer&rows=25&wt=json'
      ).to_return(File.open('spec/fixtures/api_plos_biology_search.raw'))

      stub_request(:get,
        'http://api.plos.org/search?facet=false&fl=id,pmid,publication_date,received_date,accepted_date,title,cross_published_journal_name,author_display,editor_display,article_type,affiliate,subject,financial_disclosure&fq%5B%5D=doc_type:full&fq%5B%5D=!article_type_facet:%22Issue%20Image%22&q=id:%2210.1371/journal.pcbi.1002727%22&rows=1&wt=json'
      ).to_return(File.open('spec/fixtures/api_plos_journal.pcbi.1002727.raw'))

      stub_request(:get,
        %r{http://alm.plos.org/api/v3/articles\?api_key=.*&ids=10.1371/journal.pcbi.1002727(&info=history&source=crossref,pubmed,scopus)?$},
      ).to_return(File.open('spec/fixtures/alm_api_journal.pcbi.1002727.raw'))

      stub_request(:get,
        %r{http://alm.plos.org/api/v3/articles\?api_key=.*&ids=10.1371/journal.pcbi.1002727&info=event&source=counter,pmc,citeulike,twitter,researchblogging,nature,scienceseeker,mendeley$},
      ).to_return(File.open('spec/fixtures/alm_api_journal.pcbi.102727.event.raw'))

    end

    it 'loads the articles result page', js: true do
      visit '/'
      fill_in 'everything', with: 'cancer'
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
elsif Search.crossref?
  describe "generate report", :type => :feature do
    before :each do
      stub_request(
        :get,
        "http://api.crossref.org/works?query=A%20Future%20Vision%20for%20PLOS" \
        "%20Computational%20Biology&rows=25&offset=0"
      ).to_return(File.open("spec/fixtures/api_crossref_future_vision.raw"))

      stub_request(:get,
        %r{http://alm.plos.org/api/v3/articles\?api_key=.*&ids=10.1371/journal.pcbi.1002727(&info=history&source=crossref,pubmed,scopus)?$},
      ).to_return(File.open('spec/fixtures/alm_api_journal.pcbi.1002727.raw'))

      stub_request(:get,
        %r{http://alm.plos.org/api/v3/articles\?api_key=.*&ids=10.1371/journal.pcbi.1002727&info=event&source=counter,pmc,citeulike,twitter,researchblogging,nature,scienceseeker,mendeley$},
      ).to_return(File.open('spec/fixtures/alm_api_journal.pcbi.102727.event.raw'))
    end

    it "loads the articles result page", js: true do
      visit "/"

      fill_in "everything",
        with: "A Future Vision for PLOS Computational Biology"

      click_button "Search"

      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).to have_button("Preview List (0)", disabled: true)
      first(".article-info.cf").find("input.check-save-article").click

      expect(page).to have_button("Preview List (1)")
      find_button("Preview List (1)").click
      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).not_to have_content "What Do I Want from the Publisher of the Future?"
      click_button "Create Report"

      expect(page).to have_content("Metrics Data")
      expect(page).to have_content("Visualizations")
      click_link("Visualizations")

      expect(page).to have_css('#article_usage_div svg')
    end
  end
end
