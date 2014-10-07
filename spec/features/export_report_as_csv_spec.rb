require "spec_helper"

# It is currently not possible to check the content of a CSV with Poltergeist:
# http://stackoverflow.com/q/15739423/790483

describe "export report as csv", :type => :feature do
  def search(keyword)
      visit "/"
      fill_in "everything", with: keyword
      click_button "Search"
  end

  def preview
    expect(page).to have_button("Preview List (2)")
    find_button("Preview List (2)").click
  end

  def get_csv
    click_button "Create Report"

    expect(page).to have_content("Metrics Data")
    within(".report-downloads") do
      click_link("Metrics Data")
    end
    page.response_headers["Content-Type"].should eq("text/csv")
  end

  if Search.plos?
    before do
      stub_request(:get,
        "http://api.plos.org/search?facet=true&facet.field=cross_published_journal_key&facet.mincount=1&fq=doc_type:full&fq=!article_type_facet:%22Issue%20Image%22&q=*:*&rows=0&wt=json"
      ).to_return(File.open("spec/fixtures/solr_request_get_journal_name_key.raw"))

      stub_request(:get,
        "http://api.plos.org/search?facet=false&fl=id,pmid,publication_date,received_date,accepted_date,title,cross_published_journal_name,author_display,editor_display,article_type,affiliate,subject,financial_disclosure&fq=doc_type:full&fq=!article_type_facet:%22Issue%20Image%22&hl=false&q=everything:cancer&rows=25&wt=json"
      ).to_return(File.open("spec/fixtures/api_plos_biology_search.raw"))
    end

    it "downloads the csv", js: true do
      stub_request(:get,
        %r{#{APP_CONFIG["alm"]["url"]}/api/v3/articles\?api_key=.*&ids=(?=.*10.1371/journal.pcbi.1002972)(?=.*)(?=.*10.1371/journal.pcbi.1002727).*(&info=history&source=crossref,pubmed,scopus)?$},
      ).to_return(File.open("spec/fixtures/alm_api_two_articles.raw"))

      stub_request(:get,
        %r{#{APP_CONFIG["alm"]["url"]}/api/v3/articles\?api_key=.*&ids=10.1371/journal.pcbi.1002727&info=event&source=counter,pmc,citeulike,twitter,researchblogging,nature,scienceseeker,mendeley$},
      ).to_return(File.open("spec/fixtures/alm_api_journal.pcbi.102727.event.raw"))

      search("cancer")
      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).to have_button("Preview List (0)", disabled: true)

      first(".article-info.cf").find("input.check-save-article").click
      all(".article-info.cf")[5].find("input.check-save-article").click

      preview

      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).to have_content "New Methods Section in PLOS Computational Biology"
      expect(page).not_to have_content "Correction: A Biophysical Model of the Mitochondrial Respiratory System and Oxidative Phosphorylation"
      click_button "Create Report"

      get_csv
    end
  elsif Search.crossref?
    before do
      stub_request(
        :get,
        %r{http://api.crossref.org/works.*offset=0}
      ).to_return(File.open("spec/fixtures/api_crossref_future_vision.raw"))
    end

    it "downloads the csv", js: true do
      stub_request(:get,
        %r{#{APP_CONFIG["alm"]["url"]}/api/v3/articles\?api_key=.*&ids=(?=.*10.1371/journal.pcbi.1002972)(?=.*)(?=.*10.1371/journal.pcbi.1002727).*(&info=history&source=crossref,pubmed,scopus)?$},
      ).to_return(File.open("spec/fixtures/alm_api_two_articles.raw"))

      stub_request(
        :get,
        %r{http://api.crossref.org/works.*offset=50}
      ).to_return(File.open("spec/fixtures/api_crossref_future_vision_page_3.raw"))

      search("A Future Vision for PLOS Computational Biology")

      first(".article-info.cf").find("input.check-save-article").click
      expect(page).to have_button("Preview List (1)")
      click_link("3")
      all(".article-info.cf")[12].find("input.check-save-article").click

      preview

      expect(page).to have_content "A Future Vision for PLOS Computational Biology"
      expect(page).to have_content "New Methods Section in PLOS Computational Biology"
      expect(page).not_to have_content "What Do I Want from the Publisher of the Future?"

      get_csv
    end
  end
end
