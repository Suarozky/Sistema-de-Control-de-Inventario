Rails.application.routes.draw do
  root "sessions#new"

  # Sesiones
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/home", to: "home#new"

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