AlmReport::Application.routes.draw do

  root :to => "search#index"
  get "/search/advanced" => "search#index", advanced: true

  get "/search" => "search#show"
  get "/preview" => "preview#index"

  post "/update-session" => "home#update_session"
  post "/select-all-search-results" => "home#select_all_search_results"
  get "/start-over" => "home#start_over"
  get "/get-article-count" => "home#get_article_count"

  get "/reports/generate" => "reports#generate"
  get '/reports/:action/:id', :controller => "reports"

  get "/id" => "id#index", :via => :get
  get "/id" => "id#save", :via => :post

  get "/upload" => "id#upload", :via => :get
  get "/upload" => "id#process_upload", :via => :post

  get "/about" => "static_pages#about"
  get "/samples" => "static_pages#samples"

  scope "/api" do
    get "report_alm" => "api#report_alm"
  end
end
