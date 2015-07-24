module Pageable
  extend ActiveSupport::Concern

  module ClassMethods
    def pages(params, opts, config, &block)
      if opts[:all]
        limit = ENV["WORK_LIMIT"].to_i * 2
        rows = 200

        results = {}

        for page in 1 .. (limit / rows)
          params[config[:page]] = page
          params[config[:rows]] = rows

          result = yield(params, opts)

          results.merge!(result) do |key, oldval, newval|
            oldval.is_a?(Array) ? oldval + newval : newval
          end

          break if result[config[:count]].size < rows
        end

        results
      else
        yield(params, opts)
      end
    end

    def paginate(params, config)
      items = params[config[:array]]

      results = nil

      items.each_slice(config[:per_page]) do |subset|
        params[config[:array]] = subset

        result = yield(params)

        if result.is_a? Array
          results ||= []
          results.concat(result)
        elsif result.is_a? Hash
          results ||= {}
          results.merge!(result) do |key, oldval, newval|
            oldval.is_a?(Array) ? oldval + newval : newval
          end
        end
      end

      results
    end
  end
end
