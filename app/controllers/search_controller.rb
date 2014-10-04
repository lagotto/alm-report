class SearchController < ApplicationController
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

    @journals = SolrRequest.get_journal_name_key
    render "advanced"
  end
end
