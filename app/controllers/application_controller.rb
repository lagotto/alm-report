class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :display_nav
  around_filter :save_session_dois

  # Render pretty 404 and 500 pages in production
  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound,
                ActionController::UnknownController,
                AbstractController::ActionNotFound,
                ActionController::MethodNotAllowed, :with => :page_not_found

    # rescue_from StandardError, :with => :internal_error
  end

  # See comment in routes.rb and https://github.com/rails/rails/issues/671
  # for why this is necessary.
  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  def page_not_found
    @display_nav = false
    @title = "Page Not Found"
    render :template => "static_pages/page_not_found", :status => 404
  end

  def internal_error
    @display_nav = false
    @title = "Internal Error"
    render :template => "static_pages/internal_error", :status => 500
  end

  # Sets @cart based on the contents of the session, and saves it back to the
  # session after an action is run.
  def save_session_dois
    @cart = Cart.new(session[:dois])

    yield  # Run the action

    session[:dois] = @cart.items.keys
  end

  # The navigation UI element (1 Select Articles and etc) will not be displayed on the static pages
  # That is the only change for the static pages so having a whole separate layout seemed like an overkill
  # This might change in the future
  def display_nav
    @display_nav = true
  end

  # prevent the user from moving forward if the article limit has been reached
  def article_limit_reached?
    return false if @cart.size < ENV["ARTICLE_LIMIT"].to_i

    flash[:alert] = "The maximum report size is #{ENV["ARTICLE_LIMIT"].to_i} " \
                    "articles. Go to <a href=\"#{preview_path}\">Preview List</a> " \
                    "and remove articles before adding more to your selection."
    true
  end

  protected

  # Sets fields used by the UI for results paging of articles.
  # A precondition of this method is that @total_found is set appropriately.
  def set_paging_vars(current_page, results_per_page=ENV["PER_PAGE"].to_i)
    current_page = current_page.nil? ? "1" : current_page
    @start_result = (current_page.to_i - 1) * results_per_page + 1
    @end_result = @start_result + results_per_page - 1
    @end_result = [@end_result, @total_found].min
  end
end
