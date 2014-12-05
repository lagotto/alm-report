class Search
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
end
