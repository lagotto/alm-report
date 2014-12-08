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

  it "finds results by id", vcr: true do
    ENV["SEARCH"] = "plos"
    ids = [
      "10.1371/annotation/1d6063be-ff28-4a65-a3a0-bcaf076eab4b",
      "10.1371/annotation/5cdf6105-2a52-497a-86b3-db8f4a4e439c",
      "10.1371/annotation/a8159928-d073-4b5b-8a50-c68c95b78681",
      "10.1371/journal.pcbi.1001087",
      "10.1371/journal.pmed.0010065",
      "10.1371/journal.pmed.0010069",
      "10.1371/journal.pmed.0030091",
      "10.1371/journal.pmed.0030479",
      "10.1371/journal.pmed.0040325",
      "10.1371/journal.pmed.0040345",
      "10.1371/journal.pmed.0050194",
      "10.1371/journal.pone.0003661",
      "10.1371/journal.pone.0004732",
      "10.1371/journal.pone.0009584",
      "10.1371/journal.pone.0010031",
      "10.1371/journal.pone.0013696",
      "10.1371/journal.pone.0018776"
    ]

    expect(Rails.cache).to receive(:read_multi).and_call_original
    results = Search.find_by_ids(ids)
    expect(results.size).to eq 17

    expect(Rails.cache).to receive(:read_multi).and_call_original
    expect(Search).not_to receive(:find)
    results = Search.find_by_ids(ids)

    expect(results.size).to eq 17
  end
end
