Rails.application.routes.draw do
  root "sessions#new"

  # Sesiones
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Home
  get "/home", to: "home#new"

  # Usuarios - CONSOLIDADO
  resources :users do
    collection do
      post :import       # /users/import
      get  :get_user     # /users/get_user
      get  :count        # /users/count
      get  :export       # /users/export
    end
    member do
      get :my_products   # /users/:id/my_products
    end
  end

  # Productos
  resources :products do
    collection do
      post :import
      get :get_product
      get :count
      get :export
    end
    member do
      get :transactions_history
    end
  end

  # Transacciones
  resources :transactions do
    collection do
      post :import
      get :count
      get :export
    end
  end

  # Marcas
  resources :brands do
    collection { post :import }
  end

  # Modelos
  resources :models do
    collection { post :import }
  end

  # Home export
  resources :home, only: [:new] do
    collection { get :export }
  end
end