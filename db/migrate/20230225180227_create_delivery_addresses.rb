class CreateDeliveryAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :delivery_addresses do |t|
      t.string :country
      t.string :region
      t.string :first_name
      t.string :last_name
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :city
      t.references :order, null: false, foreign_key: true
      t.timestamps
    end
  end
end
