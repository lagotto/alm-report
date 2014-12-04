require "pry"
module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def cache(ids, opts = {}, &block)
      base = "#{self.name}:#{caller_locations(1,1)[0].label}:"
      missing = ids.map { |id| base + id }

      found = Rails.cache.read_multi(*missing)
      missing -= found.keys

      unless missing.empty?
        results = yield(missing)

        results = results.map do |result|
          Rails.cache.write(base + result.id, result)
          # Make sure we only get requested
          result if ids.include? result.id
        end.compact
      end

      found.values + (results || [])
    end
  end
end
