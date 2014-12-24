describe Cart, vcr: true do
  let(:item_ids) { ["10.1371/journal.pone.0112913"] }
  let(:search_result) { SearchResult.from_cache(item_ids.first) }
  subject { Cart.new(item_ids) }

  it "[]" do
    expect(subject["10.1371/journal.pone.0112913"]).to eq(search_result)
  end

  it "[]=" do
    expect(subject["10.1371/journal.pone.0112913"] = search_result)
      .to eq(search_result)
  end

  it "delete" do
    expect(subject.delete("10.1371/journal.pone.0112913")).to eq(search_result)
  end

  it "clone" do
    expect(subject.clone).to eq("10.1371/journal.pone.0112913" => search_result)
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
    subject.add(["10.1371/journal.pone.0113157"])
    expect(subject.dois).
      to eq(["10.1371/journal.pone.0112913", "10.1371/journal.pone.0113157"])
  end

  it "adds multiple and keeps order" do
    add = [
      "10.1371/journal.pone.0113157",
      "10.1371/journal.pone.0114307",
      "10.1371/journal.pone.0114162",
      "10.1371/journal.pone.0113930"
    ]
    subject.add(add)

    expect(subject.dois).
      to eq(item_ids + add)
  end

  it "remove" do
    subject.remove("10.1371/journal.pone.0112913")
    expect(subject.dois).to be_empty
  end

  it "remove multiple" do
    subject.remove(["10.1371/journal.pone.0112913", "10.1371/journal.pone.0113157"])
    expect(subject.dois).to be_empty
  end

  it "clear" do
    expect(subject.clear).to be_empty
  end
end
