AlmReport::Application.routes.draw do

  root :to => "search#index"
  get "/search/advanced" => "search#index", advanced: true

  get "/search" => "search#show"
  get "/preview" => "preview#index"

  match "/update-session" => "home#update_session"
  match "/select-all-search-results" => "home#select_all_search_results"
  match "/start-over" => "home#start_over"
  match "/get-article-count" => "home#get_article_count"

  match "/reports/generate" => "reports#generate"
  match '/reports/:action/:id', :controller => "reports"

  match "/id" => "id#index", :via => :get
  match "/id" => "id#save", :via => :post

  match "/upload" => "id#upload", :via => :get
  match "/upload" => "id#process_upload", :via => :post

  match "/about" => "static_pages#about"
  match "/samples" => "static_pages#samples"

  scope "/api" do
    get "report_alm" => "api#report_alm"
  end

  # Any other routes are handled here, as ActionDispatch prevents RoutingError
  # from hitting ApplicationController::rescue_action).  See
  # https://github.com/rails/rails/issues/671
  # BE SURE TO KEEP THIS AS THE LAST LINE!
  match "*path", :to => "application#routing_error"
end
