class Search
  include Cacheable
  include Pageable

  def self.find(query, opts = {})
    pages(query, opts, page: :current_page, rows: :rows, count: :docs) do |query, opts|
      if plos?
        SearchPlos.new(query, opts).run
      elsif crossref?
        SearchCrossref.new(query, opts).run
      elsif dataone?
        SearchDataone.new(query, opts).run
      end
    end
  end

  def self.plos?
    ENV["SEARCH"] == "plos"
  end

  def self.crossref?
    ENV["SEARCH"] == "crossref"
  end

  def self.dataone?
    ENV["SEARCH"] == "dataone"
  end

  def self.find_by_ids(ids)
    cache(ids, expires_in: 1.day) do |ids|
      find({ids: ids})[:docs]
    end
  end
end
