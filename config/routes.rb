Rails.application.routes.draw do
  root "branches#index"
  resources :branches do # /branches/:branch_id
    get :menu # /menu

    resources :branch_menu_items,
      only: [ :new, :create, :edit, :update, :destroy ] # /branch_menu_items
  end
  resources :menu_items
end
