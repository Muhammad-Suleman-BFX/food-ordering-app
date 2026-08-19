Rails.application.routes.draw do
  root "branches#index"
  resources :branches do
    get :menu
    resources :branch_menu_items,
      only: [ :new, :create, :edit, :update, :destroy ]
  end
  resources :menu_items
  resources :carts
end
