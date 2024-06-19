Rails.application.routes.draw do
  get 'users/:id/billing_address', to: 'billing_addresses#show', as: :billing_address
  post 'users/:id/billing_address', to: 'billing_addresses#create', as: :create
  patch 'users/:id/billing_address', to: 'billing_addresses#update', as: :update


  root   "static_pages#home"
  get    "/help",   to: "static_pages#help"
  get    "/about",  to: "static_pages#about"
  get    "/contact",to: "static_pages#contact"
  get    "/signup", to: "users#new"
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  
  resource :billing_address, only: [:show, :create, :update]
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  get '/microposts', to: 'static_pages#home'
end
