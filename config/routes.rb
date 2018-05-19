Rails.application.routes.draw do
  # StaticPages
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  # Users
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  resources :users do
    member do
      get :following, :followers
    end
  end
  # Relationships
  resources :relationships, only: [:create, :destroy]
  # Micropost
  resources :microposts, only: [:create, :destroy]
  # Account Activations
  resources :account_activations, only: [:edit]
  # Password Resets
  resources :password_resets,     only: [:new, :create, :edit, :update]
  # Sessions
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
end
