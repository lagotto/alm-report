require 'spec_helper'

describe HomeController do
  describe 'GET index' do
    it 'renders the index template' do
      stub_request(:get,
        "http://api.plos.org/search?facet=true&facet.field=cross_published_journal_key&facet.mincount=1&fq=!article_type_facet:%22Issue%20Image%22&q=*:*&rows=0&wt=json"
      ).to_return(File.open('spec/fixtures/solr_request_get_journal_name_key.raw'))
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET add_articles' do
    it 'renders the add_articles template' do
      stub_request(:get,
        "http://api.plos.org/search?author=&author_country=&commit=Search&cross_published_journal_name=All%20Journals&datepicker1=&datepicker2=&everything=cancer&facet=false&financial_disclosure=&fl=id,pmid,publication_date,received_date,accepted_date,title,cross_published_journal_name,author_display,editor_display,article_type,affiliate,subject,financial_disclosure&fq=!article_type_facet:%22Issue%20Image%22&hl=false&institution=&publication_days_ago=-1&q=parameters:utf8=%E2%9C%93&rows=25&subject=&wt=json"
      ).to_return(File.open('spec/fixtures/api_plos_cancer_search.raw'))
      get :"add_articles", parameters: "utf8=✓&everything=cancer&author=&author_country=&institution=&publication_days_ago=-1&datepicker1=&datepicker2=&subject=&cross_published_journal_name=All+Journals&financial_disclosure=&commit=Search"
      expect(response).to render_template('add_articles')
    end
  end
end
