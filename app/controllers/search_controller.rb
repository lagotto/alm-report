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

  def filter
    l = session[:params]
    l[:filters].push({ params[:facet] => params[:value] })

    redirect_to search_path(l)
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
    @journals = Solr::Request.get_journals
  end
end
