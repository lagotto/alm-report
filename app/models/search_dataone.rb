class SearchDataone
  JOURNALS = {
    "DRYAD" => "Dryad Data Repository"
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
