YogiBerraScoreboard::Application.routes.draw do
  resources :caught_exceptions, :only => [:index, :show]
  match "/help",    to: 'static_pages#help'
  root :to => 'caught_exceptions#index'
end
