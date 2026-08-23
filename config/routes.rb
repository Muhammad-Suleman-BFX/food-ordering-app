Rails.application.routes.draw do
  root "orders#start"

  # Ordering flow
  get   "order/start",        to: "orders#start",        as: :order_start
  post  "order/set_branch",   to: "orders#set_branch",   as: :order_set_branch
  post  "orders/place",       to: "orders#place",        as: :place_order

  # Current cart
  get   "cart",               to: "carts#current",       as: :current_cart

  resources :branches do
    member do
      get :menu
    end
    resources :branch_menu_items, only: [ :new, :create, :edit, :update, :destroy ]
  end

  resources :menu_items
  resources :carts, except: [ :index, :show ]
  resources :cart_items, only: [ :create, :update, :destroy ]
  resources :orders, except: [ :edit, :update, :destroy ]
end
