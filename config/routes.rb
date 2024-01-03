Rails.application.routes.draw do
  root to: "pages#home"

  devise_for :users
  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  resources :products
  resources :orders do
    resources :address, only: [:new, :edit]
  end

  get "/confirmation", to: "orders#confirmation"

  get "/cart", to: "carts#show"
  resources :cart, only: [:show] do
    resources :cart_items, only: [:create, :destroy]
  end

  post "/create_paypal_order", :to => "payments#create_paypal_order"
  post "/capture_paypal_order", :to => "payments#capture_paypal_order"
end
