class AddCartReferenceToOrder < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :cart, index: true
  end
end
