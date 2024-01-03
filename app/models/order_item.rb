class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  def price
    return self.product.price
  end

end
