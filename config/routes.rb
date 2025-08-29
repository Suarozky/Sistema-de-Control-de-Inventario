Rails.application.routes.draw do
  root "sessions#new"
  get  "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/home", to: "home#new"

  resources :brands do
    collection { post :import }
  end
resources :products

  resources :models do
    collection { post :import }
  end
end
