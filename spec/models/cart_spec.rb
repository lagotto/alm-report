require 'rails_helper'

describe Cart do
  let(:item_ids) { ["10.1371/journal.pone.0010031"] }
  let(:search_result) { SearchResult.from_cache(item_ids.first) }
  subject { Cart.new(item_ids) }

  before do
    stub_request(:get, /api.crossref.org\/works/).
      to_return(File.open('spec/fixtures/api_crossref_single_doi.raw'))
  end

  it "[]" do
    expect(subject["10.1371/journal.pone.0010031"]).to eq(search_result)
  end

  it "[]=" do
    expect(subject["10.1371/journal.pone.0010031"] = search_result)
      .to eq(search_result)
  end

  it "delete" do
    expect(subject.delete("10.1371/journal.pone.0010031")).to eq(search_result)
  end

  it "clone" do
    expect(subject.clone).to eq("10.1371/journal.pone.0010031" => search_result)
  end

  it "size" do
    expect(subject.size).to eq(1)
  end

  it "empty? is false" do
    expect(subject.empty?).to be false
  end

  it "empty? is true" do
    subject.clear
    expect(subject.empty?).to be true
  end

  it "add" do
    subject.add(["10.1371/journal.pmed.0008763"])
    expect(subject.dois).
      to eq(["10.1371/journal.pone.0010031", "10.1371/journal.pmed.0008763"])
  end

  it "remove" do
    subject.remove("10.1371/journal.pone.0010031")
    expect(subject.dois).to be_empty
  end

  it "remove multiple" do
    subject.remove(["10.1371/journal.pone.0010031", "10.1371/journal.pmed.0008763"])
    expect(subject.dois).to be_empty
  end

  it "clear" do
    expect(subject.clear).to be_empty
  end
end
