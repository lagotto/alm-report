require "spec_helper"

describe SearchCrossref do
  it "considers offsets 0-based" do
    search = SearchCrossref.new(everything: "biology", current_page: 2)
    search.offset.should eq(25)
  end
end
