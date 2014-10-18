class SearchController < ApplicationController
  before_filter { journals if Search.plos? }

  def index
    params[:advanced] ? advanced : simple
  end

  def show
    @tab = :select_articles
    @title = "Add Articles"

    @results, @total_found, @metadata = Search.find(params)

    if @cart.items.present?
      @results.each do |result|
        result.checked = true if @cart.items.has_key?(result.id)
      end
    end

    set_paging_vars(params[:current_page])
  end

  private

  def simple
    @tab = :select_articles

    render "simple"
  end

  def advanced
    @tab = :select_articles
    @title = "Advanced Search"

    render "advanced"
  end

  # PLOS

  def journals
    @journals = if params[:advanced]
      SolrRequest.get_journals
    else
      # Add a "All Journals" entry
      { SolrRequest::ALL_JOURNALS => SolrRequest::ALL_JOURNALS }.
        merge(SolrRequest.get_journals)
    end
  end
end
