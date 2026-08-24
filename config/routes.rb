Rails.application.routes.draw do
  root "home#index"

  # API (JSON only) — customer ordering
  namespace :api do
    resources :branches, only: [ :index ] do
      collection do
        get :nearest
      end
      member do
        get :menu
      end
    end

    resources :carts, only: [ :create, :show ] do
      member do
        post :checkout
      end
      resources :items, controller: "cart_items", only: [ :create, :update, :destroy ]
    end
  end

  # Admin HTML
  resources :branches do
    member do
      get :menu
    end
    resources :branch_menu_items, only: [ :new, :create, :edit, :update, :destroy ]
  end

  resources :menu_items
  resources :orders, only: [ :index, :show ]
end
