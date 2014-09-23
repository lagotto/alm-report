require 'spec_helper'

describe Cart do
  let(:item_ids) { ["10.1371/journal.pone.0010031"] }

  subject { Cart.new(item_ids) }

  it "[]" do
    expect(subject["10.1371/journal.pone.0010031"]).to eq(1410868245)
  end

  it "[]=" do
    expect(subject["10.1371/journal.pone.0010031"] = 1410868258)
      .to eq(1410868258)
  end

  it "delete" do
    expect(subject.delete("10.1371/journal.pone.0010031")).to eq(1410868245)
  end

  it "clone" do
    expect(subject.clone).to eq("10.1371/journal.pone.0010031" => 1410868245)
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

  it "merge! add" do
    subject.merge!("10.1371/journal.pmed.0008763" => 1410868258)
    expect(subject.dois).to eq("10.1371/journal.pone.0010031"=>1410868245,
      "10.1371/journal.pmed.0008763"=>1410868258)
  end

  it "merge! update" do
    subject.merge!("10.1371/journal.pone.0010031" => 1410868258)
    expect(subject.dois).to eq("10.1371/journal.pone.0010031" => 1410868258)
  end

  it "except!" do
    subject.except!("10.1371/journal.pone.0010031")
    expect(subject.dois).to be_empty
  end

  it "except! array" do
    subject.except!(["10.1371/journal.pone.0010031", "10.1371/journal.pmed.0008763"])
    expect(subject.dois).to be_empty
  end

  it "clear" do
    expect(subject.clear).to be_empty
  end
end
