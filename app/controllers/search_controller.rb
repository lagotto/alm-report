class SearchController < ApplicationController
  before_filter :journals

  def index
    params[:advanced] ? advanced : simple
  end

  private

  def simple
    @tab = :select_articles
    @title = "Add Articles"

    @results, @total_found = Search.find(params)

    if @cart.items.present?
      @results.each do |result|
        result.checked = true if @cart.items.has_key?(result.id)
      end
    end

    set_paging_vars(params[:current_page])
    render "simple"
  end

  def advanced
    @tab = :select_articles
    @title = "Advanced Search"

    render "advanced"
  end

  def journals
    @journals = SolrRequest.get_journals
  end
end
