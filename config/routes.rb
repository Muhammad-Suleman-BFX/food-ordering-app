Rails.application.routes.draw do
  root "branches#index"
  resources :branches
  resources :menu_items
  resources :branch_menu_items
end
