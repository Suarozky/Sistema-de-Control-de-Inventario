Rails.application.routes.draw do
  root "sessions#new"
  get  "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/home", to: "home#new"
  get "/users", to: "users#new"

  get "/users/:id/my_products", to: "users#my_products", as: :user_products


  resources :brands do
    collection { post :import }
  end
resources :products
resources :users

  resources :models do
    collection { post :import }
  end

  resources :users do
  collection { post :import }
end

resources :products do
  collection { post :import }
end

resources :home, only: [:new] do
  collection do
    get :export
  end
end



  resources :products do
  member do
    get :transactions_history
  end
end

resources :users do
  member do
    get :my_products
  end
end


end
