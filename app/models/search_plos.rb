class SearchPlos
  def initialize(query, opts = {})
    @query = query
    clean_query
    parse_dates
    @fl = opts[:fl]
  end

  def run
    q = SolrRequest.new(@query, @fl)
    q.query
  end

  private

  def parse_dates
    start_date, end_date = SolrRequest.parse_date_range(
      @query.delete(:publication_days_ago),
      @query.delete(:datepicker1),
      @query.delete(:datepicker2)
    )
    date_range = SolrRequest.build_date_range(start_date, end_date)
    @query[:publication_date] = date_range if date_range.present?
  end

  def clean_query
    @query[:publication_days_ago] ||= -1
    @query.except! %i(utf8 commit controller action)
  end
end
