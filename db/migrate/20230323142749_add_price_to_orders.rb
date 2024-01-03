class AddPriceToOrders < ActiveRecord::Migration[7.0]
  def change
    add_monetize :orders, :price, currency: { present: true }
    add_monetize :orders, :delivery_fee, currency: { present: true }
  end
end
