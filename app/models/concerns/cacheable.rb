module Cacheable
  extend ActiveSupport::Concern

  included do
    extend HelperMethods
  end

  module HelperMethods
    def cache(method_name, opts = {})
      uncached_method = method(method_name)
      key_base = "#{self.name}::#{method_name}"

      self.instance_eval <<-CACHED
        #{uncached_method.source.sub(method_name.to_s, "uncached_" + method_name.to_s)}

        def #{method_name}(ids)
          cached_results = ids.map do |id|
            result = Rails.cache.fetch("#{key_base}::" + id)
            if result
              ids -= [id]
            end
            result
          end.compact

          results = uncached_#{method_name}(ids)

          results.each do |result|
            Rails.cache.write("#{key_base}::" + result.id)
          end

          results += cached_results
        end
      CACHED
    end
  end
end
