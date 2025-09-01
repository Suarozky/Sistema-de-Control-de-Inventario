Rails.application.routes.draw do
  root "sessions#new"

  # Sesiones
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/home", to: "home#new"

  # API v1
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :transactions, only: [:index, :show, :create, :update, :destroy]
    end
  end

  resources :users do
    collection do
      post :import       
      get  :count        
      get  :export      
    end
    member do
      get :my_products   
    end
  end

  resources :products do
    collection do
      post :import
      get :count
      get :export
    end
    member do
      get :transactions_history
    end
  end

  resources :transactions do
    collection do
      post :import
      get :count
      get :export
    end
  end

  resources :brands do
    collection { post :import }
  end

  resources :models do
    collection { post :import }
  end

  resources :home, only: [:new] do
    collection { get :export }
  end
end