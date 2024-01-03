puts "Creating users..."
u = User.new(email: "m@gmail.com", password: "123456", password_confirmation: "123456")
u.save

u = User.new(email: "miguel.aguilera.croasdaile@gmail.com", password: "123456", password_confirmation: "123456", admin: true)
u.save

puts "Creating products..."
9.times do
  product = Product.new(
    name: Faker::Commerce.product_name,
    description: Faker::Coffee.notes,
    quantity: 1,
    price: (5..20).to_a.sample * 10,
    delivery_fee: (1..5).to_a.sample,
    size: ["XS", "S", "M", "L", "XL"].sample,
    year: ["1980s", "1990s", "2000s", "2010s", "2020s"].sample,
    brand: ["Gildan", "Hanes", "Fruit of the Loom", "Screen Stars", "Port and Company"].sample,
    material: ["100% Cotton", "50/50 Poly Cotton Blend"].sample,
    condition: ["Trashed", "Fair", "Good", "Like New", "New"].sample,
    color: ["Black", "White", "Yellow"].sample,
    measurements: "#{(25..40).to_a.sample} x #{(25..40).to_a.sample}",
  )
  product.photos.attach(io: File.open("app/assets/images/tee.jpeg"), filename: "tee.jpeg", content_type: "image/jpeg")
  puts product.save!
end
