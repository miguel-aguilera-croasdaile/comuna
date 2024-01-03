class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    # view helpers
    @order_items = @order.order_items
    @order_subtotal = @order.order_items.sum { |order_item| (order_item.price * order_item.quantity) }
    @order_total = @order_subtotal + @order.delivery_fee
  end

  def new
    @order = Order.new
    @delivery_address = @order.build_delivery_address
    # view helpers
    @order_items = @cart.cart_items.select { |cart_item| cart_item.product.available? }
    @order_delivery_fee = @order_items.sum { |order_item| order_item.product.delivery_fee * order_item.quantity }
    @order_subtotal = @order_items.sum { |order_item| order_item.price * order_item.quantity }
    @order_total = @order_subtotal + @order_delivery_fee
  end

  def create
    @order = Order.new(order_params)
    @order_items = @cart.cart_items.select { |cart_item| cart_item.product.available? }
    if @order.valid?
      @order.cart = @cart
      @order.checkout_session_id = session[:session_id]
      if user_signed_in?
        @order.user = current_user
      end
      @order_items.each do |cart_item|
        OrderItem.create!(product: cart_item.product, quantity: cart_item.quantity, order: @order)
      end
      @order.price = @order.order_items.sum { |order_item| order_item.price * order_item.quantity }

      if @order.delivery_method == "Shipping"
        @order.update(delivery_fee: @order.order_items.sum { |order_item| order_item.product.delivery_fee * order_item.quantity })
      else
        @order.delivery_address.destroy if @order.delivery_address
        @order.update(delivery_fee: 0.0)
      end
      @order.save!
      redirect_to order_path(@order)
    else
      redirect_to new_order_path, alert: "Invalid form, please try again. (#{@order.errors.count} errors)"
    end
  end

  def edit
    @order = Order.find(params[:id])
    @order_items = @order.order_items
    if @order.delivery_address
      @delivery_address = @order.delivery_address
    else
      @delivery_address = @order.build_delivery_address
    end
    # View Helpers
    @order_items = @order.order_items
    @order_delivery_fee = @order_items.sum { |order_item| order_item.product.delivery_fee * order_item.quantity }
    @order_subtotal = @order_items.sum { |order_item| order_item.price * order_item.quantity }
    @order_total = @order_subtotal + @order_delivery_fee
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      if @order.delivery_method == "Shipping"
        @order.update(delivery_fee: @order.order_items.sum { |order_item| order_item.product.delivery_fee * order_item.quantity })
      else
        @order.delivery_address.destroy if @order.delivery_address
        @order.update(delivery_fee: 0)
      end
      redirect_to order_path(@order)
    else
      redirect_to edit_order_path(@order), alert: "Invalid form, please try again."
    end
  end

  def confirmation
    @order = Order.find_by(paypal_transaction_id: params[:transaction_id])
    render json: { errors: ["Not Authorized"] }, status: :unauthorized unless (user_signed_in? && current_user == @order.user) || session[:session_id] == @order.checkout_session_id
  end

  private

  def order_params
    params.require(:order).permit(
      :cart,
      :cart_id,
      :id,
      :price,
      :currency,
      :status,
      :user,
      :contact_email,
      :contact_number,
      :delivery_method,
      :delivery_city,
      :delivery_fee,
      delivery_address_attributes: %i[id country region first_name last_name address_line_1 address_line_2 postal_code city],
    )
  end
end
