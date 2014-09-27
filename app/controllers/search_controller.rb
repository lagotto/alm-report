class SearchController < ApplicationController
  def index
    @tab = :select_articles
    @title = "Add Articles"

    @results, @total_found = Search.find(params)

    # search executed from the advanced search page
    # convert the journal key to journal name
    if params[:unformattedQueryId] && params[:filterJournals]
      @filter_journal_names = params[:filterJournals].map do |journal|
        APP_CONFIG["journals"][journal] if APP_CONFIG["journals"]
      end.compact
    end

    if @cart.items.present?
      @results.each do |result|
        result.checked = true if @cart.items.has_key?(result.id)
      end
    end

    set_paging_vars(params[:current_page])
  end

  def advanced
    @tab = :select_articles
    @title = "Advanced Search"

    @journals = SolrRequest.get_journal_name_key
  end
end
