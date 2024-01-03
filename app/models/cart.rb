class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_one :order
  has_many :cart_items, dependent: :delete_all

  def clear
    self.cart_items.each{ |ci| ci.destroy}
  end

  def total
    t = 0
    self.cart_items.each {|ci| t+= ci.price}
    return t
  end

  def currency
    return self.cart_items.first.product.price_currency
  end
end
