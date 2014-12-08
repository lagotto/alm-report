class SearchPlos

  JOURNALS = {
    "PLoSONE" => "PLOS ONE",
    "PLoSGenetics" => "PLOS Genetics",
    "PLoSBiology" => "PLOS Biology",
    "PLoSPathogens" => "PLOS Pathogens",
    "PLoSCompBiol" => "PLOS Computational Biology",
    "PLoSMedicine" => "PLOS Medicine",
    "PLoSNTD" => "PLOS Neglected Tropical Diseases",
    "PLoSCollections" => "PLOS Collections"
  }

  def initialize(query, opts = {})
    @query = query
    @fl = opts[:fl]
  end

  def run
    q = Solr::Request.new(@query, @fl)
    q.query
  end
end
