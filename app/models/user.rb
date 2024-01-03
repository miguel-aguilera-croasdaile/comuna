class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  after_create :create_user_cart
  has_many :orders
  has_one :cart

  def create_user_cart
    cart = Cart.new(user: self, guest: false)
    cart.save!
  end

end
