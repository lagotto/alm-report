class Search
  def self.find(query, opts = {})
    if plos?
      SearchPlos.new(query, opts).run
    elsif crossref?
      SearchCrossref.new(query, opts).run
    end
  end

  def self.find_by_ids(ids)
    query = if plos?
      {id: ids.join(" OR ") }
    elsif crossref?
      {filter: ids.map{|id| "doi:#{id}"}.join(",")}
    end
    find(query)
  end

  def self.plos?
    APP_CONFIG['search'] == 'plos'
  end

  def self.crossref?
    APP_CONFIG['search'] == 'crossref'
  end
end
