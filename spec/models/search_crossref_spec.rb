require "spec_helper"

describe SearchCrossref do
  it "considers offsets 0-based" do
    search = SearchCrossref.new(everything: "biology", current_page: 2)
    search.offset.should eq(25)
  end

  it "handles :sort parameter" do
    search = SearchCrossref.new(sort: "published desc")
    search.request[:sort].should eq("published")
    search.request[:order].should eq("desc")
  end
end
