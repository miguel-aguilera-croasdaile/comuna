class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.boolean :guest, default: true
      t.string :status, default: "PENDING"
      t.string :checkout_session_id
      t.string :paypal_transaction_id
      t.string :paypal_token
      t.time :paypal_token_expiration_time
      t.string :contact_email
      t.string :contact_number
      t.string :delivery_method
      t.timestamps
    end
  end
end
