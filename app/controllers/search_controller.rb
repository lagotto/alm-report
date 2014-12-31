class SearchController < ApplicationController
  before_filter { journals if Search.plos? }

  def index
    search_params[:advanced] ? advanced : simple
  end

  def show
    @tab = :select_articles
    @title = "Add Articles"

    session[:params] = search_params
    search = Search.find(search_params)

    @results = search[:docs]
    @total_found = search[:found]
    @metadata = search[:metadata]

    session[:facets] = search[:facets]
    @facets = search[:facets]

    if @cart.items.present?
      @results.each do |result|
        result.checked = true if @cart.items.has_key?(result.id)
      end
    end

    set_paging_vars(search_params[:current_page])
  end

  def facets
    @facets = session[:facets]
    redirect_to(root_path) && return unless @facets

    search_params[:facets].each do |facet|
      @facets.toggle(name: facet[:name], value: facet[:value])
    end

    redirect_to search_path(session[:params].merge(@facets.params))
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

  private

  def search_params
    params.permit :everything, :author, :author_country, :institution,
      :publication_days_ago, :datepicker1, :datepicer2, :subject,
      :cross_published_journal_name, :financial_disclosure, :filters,
      :queryFieldId, :startDateAsStringId, :endDateAsStringId,
      :unformattedQueryId, :journalOpt, :facets

    params.delete_if do |k, v|
      v == "" || v == [""]
    end
  end
end
