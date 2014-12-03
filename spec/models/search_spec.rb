require "spec_helper"

api_urls = {
  plos: "http://api.plos.org/search?facet=false&fl=id,pmid,publication_date," \
    "received_date,accepted_date,title,cross_published_journal_name," \
    "author_display,editor_display,article_type,affiliate,subject," \
    "financial_disclosure&fq=doc_type:full&" \
    "fq=!article_type_facet:%22Issue%20Image%22&" \
    "&hl=false&q=everything:cancer&rows=25&wt=json",
  crossref: %r{http://api.crossref.org/works}
}

describe Search do
  it "queries PLOS's API if search is set to PLOS" do
    ENV["SEARCH"] = "plos"
    stub = stub_request(:get, api_urls[:plos]).
      to_return(File.open("spec/fixtures/api_plos_cancer_search.raw"))

    Search.find(everything: "cancer")

    stub.should have_been_requested
  end

  it "queries CrossRef's API if search is set to CrossRef" do
    ENV["SEARCH"] = "crossref"

    stub = stub_request(:get, api_urls[:crossref]).
      to_return(File.open("spec/fixtures/api_crossref_cancer.raw"))

    Search.find(everything: "cancer")

    stub.should have_been_requested
  end

end
