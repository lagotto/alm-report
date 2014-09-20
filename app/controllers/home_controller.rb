
# TODO: separate out the methods into multiple Controller classes, if necessary.
# Right now this is the entire app except for the report page.
class HomeController < ApplicationController

  def index
    @tab = :select_articles
    @title = "Homepage"

    journals = SolrRequest.get_journal_name_key
    journals.collect! { | journal | [journal[:journal_name], journal[:journal_name]] }

    # Add a fake entry for "all journals"
    @journals = journals.unshift([SolrRequest::ALL_JOURNALS, SolrRequest::ALL_JOURNALS])
  end

  def add_articles
    @tab = :select_articles
    @title = "Add Articles"

    @results, @total_found = Search.find(params)

    # search executed from the advanced search page
    # convert the journal key to journal name
    if params[:unformattedQueryId] && params[:filterJournals]
      @filter_journal_names = params["filterJournals"].map do |journal|
        APP_CONFIG["journals"][journal] if APP_CONFIG["journals"]
      end.compact
    end

    if @cart.dois.present?
      @results.each do |result|
        result.checked = true if @card.dois.has_key?(result.id)
      end
    end

    set_paging_vars(params[:current_page])
  end

  # Update session via ajax call
  # params[:article_ids] is of the form "10.1371/journal.pone.0052192|12345678";
  def update_session
    initial_count = @cart.size

    # don't update session when article_limit reached
    return render json: { status: "limit", delta: 0 } \
      unless initial_count < APP_CONFIG["article_limit"]

    # generate hash in format doi => timestamp, observe article_limit
    article_ids = parse_article_keys(params[:article_ids], initial_count)

    case params[:mode]
    when "SAVE" then @cart.merge!(article_ids)
    when "REMOVE" then @cart.except!(article_ids.keys)
    end

    render json: { status: "success", delta: @cart.size - initial_count }
  end

  # Parse array of keys in the form "10.1371/journal.pone.0052192|12345678",
  # i.e. a doi and timestamp separated by a '|' character. Returns a hash.
  # Hash is empty if params[:article_ids] is nil or limit reached
  def parse_article_keys(keys, count = 0)
    limit = APP_CONFIG["article_limit"] - count
    return {} unless limit > 0

    article_ids = Array(keys)[0...limit].reduce({}) do |hash, id|
      fields = id.split("|")
      hash.merge(fields.first => fields.last.to_i)
    end
  end

  # Simple AJAX action that returns the count of articles stored in the session.
  def get_article_count
    render json: @cart.size
  end

  # Queries solr for the results used by select_all_search_results.
  def get_all_results
    page = params.delete(:current_page)

    # For efficiency, we want to query solr for the smallest number of results.
    # However, this is difficult because the user may have already selected
    # some articles from various pages of the search results, and there is no
    # easy way to determine the intersection of this with the search we're about
    # to do.  Using article_limit * 2 as our requested number of results handles
    # various pathological cases such as the user having checked every other
    # search result.
    limit = APP_CONFIG["article_limit"] * 2

    # solr usually returns 500s if you try to retreive all 1000 articles at once,
    # so we do paging here (with a larger page size than in the UI).
    params[:start] = 1
    page_size = 200
    results = []
    begin
      rows = [page_size, limit - params[:start] + 1].min
      params[:rows] = rows
      docs, _ = Search.find(params, fl: "id,publication_date")
      results += docs
      params[:start] = params[:start] + rows
    end while params[:start] <= limit
    results
  end
  private :get_all_results

  # Ajax action that handles the "Select all nnn articles" link.  Selects
  # *all* of the articles from the search, not just those on the current page.
  # (Subject to the article limit.)
  def select_all_search_results
    initial_count = @cart.size

    # This is a little weird... if the user has no more capacity before the
    # article limit, return an error status, but if at least one article can
    # be added, return success.
    if initial_count >= APP_CONFIG["article_limit"]
      status = "limit"
    else
      status = "success"
      begin
        docs = get_all_results
      rescue SolrError
        logger.warn("Error querying solr: #{$!}")

        # Send a json response, instead of the rails 500 HTML page.
        respond_to do |format|
          format.json {render :json => {:status => "error"}, :status => 500}
        end
        return
      end
      docs.each do |doc|
        @cart[doc["id"]] = doc["publication_date"].strftime("%s").to_i
      end
    end

    payload = {:status => status, :delta => @cart.size - initial_count}
    respond_to do |format|
      format.json { render :json => payload}
    end
  end

  # Action that clears any DOIs in the session and redirects to home.
  def start_over
    @cart.clear
    redirect_to :action => :index
  end

  def preview_list
    @tab = :preview_list
    @title = "Preview List"
    @total_found = @cart.size
    dois = @cart.clone
    set_paging_vars(params[:current_page])

    # Convert to array, sorted in descending order by timestamp, then throw away the timestamps.
    dois = dois.sort_by{|doi, timestamp| -timestamp}.collect{|x| x[0]}
    dois = dois[(@start_result) - 1..(@end_result - 1)]
    @results = []

    data = BackendService.get_article_data_for_list_display(dois)
    @results = dois.map { |doi| SearchResult.new(data[doi]) }
  end

  def advanced
    @tab = :select_articles
    @title = "Advanced Search"

    @journals = SolrRequest.get_journal_name_key
  end
end
