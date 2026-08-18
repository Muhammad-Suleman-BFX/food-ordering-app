Rails.application.routes.draw do
  root "branches#index"
  resources :branches
end
