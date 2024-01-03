class AddPriceToProducts < ActiveRecord::Migration[7.0]
  def change
    add_monetize :products, :price, currency: { present: true }
    add_monetize :products, :delivery_fee, currency: { present: true }
  end
end
