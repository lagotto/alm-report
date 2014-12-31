require "spec_helper"

describe Facet do
  it "adds a facet" do
    @facet = Facet.new

    first = {
      :article_type => {
        "research article" => {
          "count" => 10
        }
      }
    }

    @facet.add(first)

    @facet.facets.should eq(first)
  end
end
