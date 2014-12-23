module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    def cache(ids, opts = {}, &block)
      base = self.name + ":"

      missing = ids.map { |id| base + id }
      found = Rails.cache.read_multi(*missing)
      missing -= found.keys

      if missing.present?
        results = yield(missing.map { |id| id[base.length..-1] })

        results = results.map do |result|
          Rails.cache.write(base + result.id, result, opts)
          result if ids.include? result.id
        end.compact
      end

      results ||= []
      results += found.values

      results.sort_by { |r| ids.index r.id }
    end
  end
end
