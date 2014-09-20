require 'pry'

class Search
  def self.find(query, opts = {})
    if plos?
      SearchPlos.new(query, opts).run
    elsif crossref?
      SearchCrossref.new(query, opts).run
    end
  end

  def self.plos?
    APP_CONFIG['search'] == 'plos'
  end

  def self.crossref?
    APP_CONFIG['search'] == 'crossref'
  end
end
