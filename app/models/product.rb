class Product < ApplicationRecord
  monetize :price_cents
  monetize :delivery_fee_cents
  has_many_attached :photos

  validates :name, :size, :price, :delivery_fee, presence: true

  def update_available_quantity(quantity_to_remove)
    self.update(quantity: (self.quantity - quantity_to_remove))
  end

  def available?
    return self.quantity > 0
  end

end
