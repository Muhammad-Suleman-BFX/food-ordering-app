Rails.application.routes.draw do
  root "branches#index"
  resources :branches
  resources :menu_items
end
