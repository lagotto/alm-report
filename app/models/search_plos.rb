class SearchPlos
  def initialize(query, opts = {})
    @query = query
    @fl = opts[:fl]
  end

  def run
    q = SolrRequest.new(@query, @fl)
    q.query
  end
end
