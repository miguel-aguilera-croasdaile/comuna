class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create_paypal_order
    @order = Order.find(params[:storeOrderID])
    @order.check_paypal_token_validity()

    paypal_order_items = @order.generate_paypal_order_items()
    paypal_shipping_preference_and_information = @order.generate_paypal_shipping_information()

    url = URI("https://api-m.sandbox.paypal.com/v2/checkout/orders")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Prefer"] = "return=representation"
    request["Authorization"] = "Bearer #{@order.paypal_token}"
    request.body = @order.generate_request_body(paypal_order_items, paypal_shipping_preference_and_information)

    response = https.request(request)
    parsed_response = JSON.parse(response.read_body)

    render json: { status: parsed_response["status"], order_id: parsed_response["id"] }
  end

  def capture_paypal_order
    @order = Order.find(params[:storeOrderID])
    @order.check_paypal_token_validity()

    url = URI("https://api-m.sandbox.paypal.com/v2/checkout/orders/#{params[:paypalOrderID]}/capture")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Prefer"] = "return=representation"
    request["Authorization"] = "Bearer #{@order.paypal_token}"

    response = https.request(request)
    parsed_response = JSON.parse(response.read_body)

    render json: { status: parsed_response["status"], transaction_id: @order.paypal_transaction_id }
    if parsed_response["status"] == "COMPLETED"
      @order.update(status: parsed_response["status"], paypal_transaction_id: parsed_response["purchase_units"][0]["payments"]["captures"][0]["id"])
      @order.cart.destroy if @order.cart
    end
  end
end
