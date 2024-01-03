class CartsController < ApplicationController
  def show
    @available_products = @cart.cart_items.select { |cart_item| cart_item.product.available? }
    @unavailable_products = @cart.cart_items.select { |cart_item| !(cart_item.product.available?) }
    @cart_subtotal = @available_products.sum { |order_item| order_item.price * order_item.quantity }
  end
end
