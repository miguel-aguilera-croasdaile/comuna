class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  def name
    return self.product.name
  end

  def description
    return self.product.description
  end

  def price
    return self.product.price
  end

  def currency
    return self.product.price_currency
  end

  def photos
    return self.product.photos
  end

end
