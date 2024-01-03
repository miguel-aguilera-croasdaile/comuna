class Order < ApplicationRecord
  monetize :price_cents
  monetize :delivery_fee_cents
  belongs_to :user, optional: true
  belongs_to :cart, optional: true
  has_many :order_items, dependent: :delete_all
  has_one :delivery_address, :dependent => :destroy
  accepts_nested_attributes_for :delivery_address
  validates :contact_email, :contact_number, :delivery_method, presence: true

  # PAYPAL TOKENIZATION API CALLS

  # Method checks if order has a valid PayPal API Token
  def check_paypal_token_validity
    # Paypal Token hasn't been acquired or expired
    if self.paypal_token_expiration_time == nil || self.paypal_token_expiration_time < DateTime.now
      token_and_expiration = get_paypal_token()
      self.update(paypal_token: token_and_expiration[0], paypal_token_expiration_time: (DateTime.now + token_and_expiration[1]))
    end
  end

  # Method gets PayPal API Token
  def get_paypal_token
    url = URI("https://api-m.sandbox.paypal.com/v1/oauth2/token")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request.basic_auth ENV["PAYPAL_CLIENT_ID"], ENV["PAYPAL_CLIENT_SECRET"]
    request.set_form_data(grant_type: "client_credentials", ignoreCache: true, return_authn_schemes: true, return_client_metadata: true, return_unconsented_scopes: true)
    response = https.request(request)
    parsed_response = JSON.parse(response.body)
    return [parsed_response["access_token"], parsed_response["expires_in"]]
  end

  # HELPER METHODS

  # Method returns JSONified body of the request to create a PayPal Order
  def generate_request_body(order_items, shipping_information)
    return JSON.dump(
             {
               "application_context": {
                 "brand_name": "comuna",
                 "shipping_preference": shipping_information[0],
               },
               "intent": "CAPTURE",
               "purchase_units": [
                 {
                   "shipping": shipping_information[1],
                   "items": order_items,
                   "amount": {
                     "currency_code": self.price_currency,
                     "value": self.price + self.delivery_fee,
                     "breakdown": {
                       "item_total": {
                         "currency_code": self.price_currency,
                         "value": self.price,
                       },
                       "shipping": {
                         "currency_code": self.price_currency,
                         "value": self.delivery_fee,
                       },
                     },
                   },
                 },
               ],
             }
           )
  end

  # Method returns JSONified order_items hash to 'append' to API request body
  def generate_paypal_order_items
    paypal_order_items = []
    self.order_items.each do |order_item|
      paypal_order_item = {}
      paypal_order_item["name"] = order_item.product.name
      paypal_order_item["description"] = order_item.product.description
      paypal_order_item["quantity"] = order_item.quantity
      paypal_order_item["unit_amount"] = {
        currency_code: order_item.product.price_currency,
        value: order_item.price,
      }
      paypal_order_items.append(paypal_order_item)
    end
    return paypal_order_items
  end

  # Method returns a 2-length array containing shipping_preference and shipping_address hash to 'append' to API request body
  def generate_paypal_shipping_information
    case self.delivery_method
    when "Shipping"
      shipping_preference = "SET_PROVIDED_ADDRESS"
      shipping_information = {
        amount: self.delivery_fee,
        name: {
          full_name: "#{self.delivery_address.first_name} #{self.delivery_address.last_name}",
        },
        address: {
          address_line_1: self.delivery_address.address_line_1,
          address_line_2: self.delivery_address.address_line_2,
          admin_area_1: self.delivery_address.region,
          admin_area_2: self.delivery_address.city,
          postal_code: self.delivery_address.postal_code,
          country_code: self.delivery_address.country,
        },
      }
    when "Hand Delivery"
      shipping_preference = "NO_SHIPPING"
      shipping_information = {}
    end
    [shipping_preference, shipping_information]
  end
end
