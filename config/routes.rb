AlmReport::Application.routes.draw do

  root :to => "home#index"
  
  match "/add-articles" => "home#add_articles"
  
  match "/update-session" => "home#update_session"
  
  match "/clear-session" => "home#clear_session"
  
  match "/preview-list" => "home#preview_list"

  match "/reports/generate" => "reports#generate"
  
  match "/reports" => "reports#show"

end
