require "rails_helper"
require "pry"

describe Geocode do
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

  it "returns the same number of geocodes as there are addresses" do
    addresses1 = ["Slovenia"]
    results1 = Geocode.load_from_addresses(addresses1)
    expect(results1.length).to eq addresses1.length
    addresses2 = [
      "Murska Sobota, Slovenia",
      "Ljubljana, Slovenia",
      "New York, NY, United States of America"
    ]
    results2 = Geocode.load_from_addresses(addresses2)
    expect(results2.length).to eq addresses2.length
  end

  it "understands and uses country synoynms" do
    addresses = ["People's Republic of China"]
    results = Geocode.load_from_addresses(addresses)
    expect(results.first[1].address).to eq "China"

    addresses = ["Rio de Janeiro, Brasil"]
    results = Geocode.load_from_addresses(addresses)
    expect(results.first[1].address).to match /Brazil/
  end

  it "handles synonyms when there are multiple addresses" do
    addresses = [
      "Beijing, People's Republic of China",
      "Rio de Janeiro, Brasil",
      "Ljubljana, Slovenia"
    ]
    results = Geocode.load_from_addresses(addresses)
    expect(results.length).to eq addresses.length
    expect(results.first[1].address).to eq ("Beijing, China")
    expect(results.to_a[1][1].address).to eq ("Rio de Janeiro, Brazil")
  end
end
