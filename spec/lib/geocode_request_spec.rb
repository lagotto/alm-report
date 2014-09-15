require "spec_helper"

describe GeocodeRequest do
  def parse_assert(expect, affil)
    location, institute = GeocodeRequest.parse_location_from_affiliate(affil)
    location.should eq(expect[0])
    institute.should eq(expect[1])
  end

  it "parses location from affiliate" do
    GeocodeRequest.parse_location_from_affiliate("").should eq(nil)
    GeocodeRequest.parse_location_from_affiliate("foo").should eq(nil)
    GeocodeRequest.parse_location_from_affiliate("foo,bar").should eq(nil)

    parse_assert([
      "Waimanalo, Hawaii, United States of America",
      "National Oceanic and Atmospheric Administration (NOAA), " \
      "National Ocean Service, National Centers for Coastal Ocean " \
      "Science-Biogeography Team and The Oceanic Institute"
    ],
      "National Oceanic and Atmospheric Administration (NOAA), " \
      "National Ocean Service, National Centers for Coastal Ocean " \
      "Science-Biogeography Team and The Oceanic Institute, Waimanalo, " \
      "Hawaii, United States of America"
    )

    parse_assert([
      "Starnberg, Germany",
      "Max-Planck-Institut fur Verhaltensphysiologie Seewiesen"
    ],
      "Max-Planck-Institut fur Verhaltensphysiologie Seewiesen, Starnberg, " \
      "Germany"
    )

    parse_assert([
      "Townsville, Queensland, Australia",
      "Australian Institute of Marine Science"
    ],
      "Australian Institute of Marine Science, Townsville, Queensland, " \
      "Australia"
    )

    parse_assert(["Henan, China", "Henan Geological Museum, Zhengzhou"],
        "Henan Geological Museum, Zhengzhou, Henan, China")
  end
end
