class PagesController < ApplicationController
  def home
  end

  def faq
  end

  def about
  end

  def checkout
    @order = Order.new()
    @delivery_address = @order.build_delivery_address
    # View Helpers
    @order_items = @cart.cart_items.select { |cart_item| cart_item.product.available? }
    @order_delivery_fee = @order_items.sum { |order_item| order_item.product.delivery_fee * order_item.quantity }
    @order_subtotal = @order_items.sum { |order_item| order_item.price * order_item.quantity }
    @order_total = @order_subtotal + @order_delivery_fee
  end
end
