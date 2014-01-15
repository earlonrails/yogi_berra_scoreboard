YogiBerraScoreboard::Application.routes.draw do
  resources :project_configurations
  resources :caught_exceptions, :only => [:index, :show]
  match "/many_exceptions", to: "caught_exceptions#many_exceptions", via: [:get, :post]
  match "/raw_query", to: "caught_exceptions#raw_query", via: [:post]
  match "/heat_map", to: "caught_exceptions#heat_map"
  match "/dismiss", to: "caught_exceptions#dismiss"
  match "/help",    to: 'static_pages#help'
  root :to => 'caught_exceptions#index'
end
