class ApplicationController < ActionController::Base
  before_action :set_cart
  before_action :store_user_location!, if: :storable_location?

  def set_cart
    @cart ||= Cart.find_by(id: session[:cart_id])
    if @cart.nil?
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
