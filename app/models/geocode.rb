require "set"

# Stores the latitude and longitude for a given address in the DB.
class Geocode < ActiveRecord::Base
  CACHE_PREFIX = "geocodes.address."

  # Map of variations of certain countries' names, to the value that we
  # have stored in the geocodes table.
  COUNTRY_SYNONYMS = {
      "brasil" => "brazil",
      "people's republic of china" => "china",
      "peoples' republic of china" => "china",
      "pr china" => "china",
      "republic of panama" => "panama",
      "the netherlands" => "netherlands",
      }

  # Contains countries where we have affiliate data of the form "City, Province, Country".
  # For all other countries the affiliate is in the form "City, Country".
  COUNTRIES_WITH_PROVINCES = Set.new([
    "Australia",
    "Canada",
    "United States of America",
  ])

  # Checks to see if any of the addresses are in the rails cache.  Returns a tuple
  # of a list of geocodes found in the cache, and a list of addresses not found.
  def self.check_cache(addresses)
    results = []
    not_in_cache = []
    addresses.each do |a|
      cached = Rails.cache.read("#{CACHE_PREFIX}#{a}")
      if cached.nil?
        not_in_cache << a
      else
        results << cached
      end
    end
    [results, not_in_cache]
  end

  # Adds the geocodes to the rails cache.
  def self.add_to_cache(geos)
    geos.each {|geo| Rails.cache.write("#{CACHE_PREFIX}#{geo.address.downcase}", geo,
        :expires_in => 1.day)}
  end

  # Performs a batch query against the addresses field of the geocodes table.
  #
  # Input: a map where the keys are the addresses that will be queried, and
  #     the values are "original" addresses which are associated with the keys.
  #
  # Output: a tuple of a map from address to geocode object, and a list of the
  #     original addresses that were found.
  def self.load_from_addresses_impl(addresses)
    geos, not_in_cache = check_cache(addresses)
    if geos.length < addresses.length
      db_geos = Geocode.where(:address => not_in_cache)
      add_to_cache(db_geos)
      geos += db_geos
    end
    results = {}
    geos.each do |geo|
      results[geo.address.downcase] = geo
    end
    results
  end

  # Attempts to load geocodes for all of the given addresses.  Batch queries
  # are used for efficiency.  Several queries may be issued, from most specific
  # (the entire address) to least specific (just the country), depending on
  # whether we find the address at the previous stage.  Returns a map
  # from input address to geocode object (not all input addresses may be present
  # in the output, if they were not found).
  def self.load_from_addresses(addresses)
    processed = addresses.map do |address|
      address.downcase!
      variations = COUNTRY_SYNONYMS.map do |synonym, canonical|
        # Address can be in multiple forms:
        # City, Province, Country
        # City, Country
        if address =~ /((?<=, )#{synonym}\Z)|\A#{synonym}\Z/
          address.sub(synonym, canonical)
        end
      end.compact
      variations.push(address) if variations.empty?
      variations.push(address[/(?<=, ).*\Z/])
      [address, Hash[*variations.compact.map { |f| [f, nil]}.flatten]]
    end

    processed = Hash[processed]
    geocodes = load_from_addresses_impl(processed.values.reduce(:merge).keys)

    processed.map do |address, variations|
      # Try to find the most specific address first.
      variations = variations.keys.sort_by { |v| v.count(",") }.reverse

      variation = variations.find do |variation|
        geocodes[variation]
      end
      { address => geocodes[variation] } if variation
    end.compact.reduce(:merge)
  end

  # Parses the author affiliates field in the article XML to retrieve the
  # location of the author. Returns a tuple of location and the institution name
  # (the latter just being everything found before the location), or nil if the
  # affiliate cannot be parsed.
  def self.parse_location_from_affiliation(affiliation)
    fields = affiliation.split(",")
    fields.map { |location| location.strip! }
    if fields.length >= 3
      offset = COUNTRIES_WITH_PROVINCES.include?(fields[-1]) ? 3 : 2
      return [fields[-offset, offset].join(", "), fields[0, fields.length - offset].join(", ")]
    else
      nil
    end
  end

end
