require "rails_helper"
require "pry"

describe Geocode do
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
