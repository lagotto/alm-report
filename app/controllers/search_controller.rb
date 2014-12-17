class SearchController < ApplicationController
  before_filter { journals if Search.plos? }

  def index
    params[:advanced] ? advanced : simple
  end

  def show
    @tab = :select_articles
    @title = "Add Articles"

    session[:params] = params

    search = Search.find(params)
    @results = search[:docs]
    @facets = search[:facets]

    session[:facets] = @facets

    @total_found = search[:found]
    @metadata = search[:metadata]

    if @cart.items.present?
      @results.each do |result|
        result.checked = true if @cart.items.has_key?(result.id)
      end
    end

    set_paging_vars(params[:current_page])
  end

  private

  def filter

  end

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
      Solr::Request.get_journals
    else
      # Add a "All Journals" entry
      { Solr::ALL_JOURNALS => Solr::ALL_JOURNALS }.
        merge(Solr::Request.get_journals)
    end
  end
end
