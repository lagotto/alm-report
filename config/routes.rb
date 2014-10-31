AlmReport::Application.routes.draw do

  root :to => "search#index"
  get "/search/advanced" => "search#index", advanced: true

  get "/search" => "search#show"
  get "/preview" => "preview#index"

  post "/update-session" => "home#update_session"
  post "/select-all-search-results" => "home#select_all_search_results"
  get "/start-over" => "home#start_over"
  get "/get-article-count" => "home#get_article_count"

  scope "reports" do
    get "generate" => "reports#generate"
    get "metrics/:id" => "reports#metrics", as: :metrics
    get "visualizations/:id" => "reports#visualizations", as: :visualizations
    get "download_data/:id" => "reports#download_data", as: :download
  end

  get "/id" => "id#index", :via => :get
  get "/id" => "id#save", :via => :post

  get "/upload" => "id#upload", :via => :get
  get "/upload" => "id#process_upload", :via => :post

  get "/about" => "static_pages#about"
  get "/samples" => "static_pages#samples"

  namespace :api do
    resources :reports
  end
end
