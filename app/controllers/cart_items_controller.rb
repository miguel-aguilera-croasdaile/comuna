class CartItemsController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    if CartItem.exists?(product: product, cart: @cart)
      flash[:alert] = "Product already in your cart! "
      redirect_to product_path(product)
    else
      if CartItem.create!(product: product, cart: @cart, quantity: 1)
        flash[:notice] = "Product added to cart."
        redirect_to product_path(product)
      else
        flash[:alert] = "Internal Error."
        redirect_to product_path(product), status: :unprocessable_entity
      end
    end
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy
    flash[:notice] = "Product removed from cart."
    redirect_to cart_path
  end
end
