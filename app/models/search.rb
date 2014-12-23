class Search
  include Cacheable

  def self.find(query, opts = {})
    if plos?
      SearchPlos.new(query, opts).run
    elsif crossref?
      SearchCrossref.new(query, opts).run
    end
  end

  def self.plos?
    ENV["SEARCH"] == "plos"
  end

  def self.crossref?
    ENV["SEARCH"] == "crossref"
  end

  def self.find_by_ids(ids)
    cache(ids, expires_in: 1.day) do |ids|
      find({ids: ids}).first
    end
  end
end
