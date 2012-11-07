Streamphish::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :shows do
    member do
      get 'download'
    end
  end
  resources :songs
  resources :tracks do
    member do
      get 'download'
    end
  end

  match "/years" => "pages#years"
  
  # SANDBOX TEST STUFF
  match "/venues" => "sandboxes#parse_venues"

  root :to => 'pages#index'

end
