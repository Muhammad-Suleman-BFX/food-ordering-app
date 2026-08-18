# frozen_string_literal: true

puts "Starting Albaik KSA seed..."

# ───────────────────────────────────────────────
# Clear existing data in reverse dependency order
# ───────────────────────────────────────────────
OrderItem.destroy_all
Order.destroy_all
CartItem.destroy_all
Cart.destroy_all
BranchMenuItem.destroy_all
MenuItem.destroy_all
Branch.destroy_all

puts "Cleared existing data."

# ───────────────────────────────────────────────
# 1. BRANCHES — Albaik KSA locations
# ───────────────────────────────────────────────
puts "Creating Albaik branches..."

branches_data = [
  {
    name: "Albaik — Jeddah Al Andalus",
    address: "Al Andalus District, Prince Mohammed bin Abdulaziz St, Jeddah 23326, KSA",
    latitude: 21.543333,
    longitude: 39.172778
  },
  {
    name: "Albaik — Jeddah Al Hamra",
    address: "Al Hamra District, Palestine Street, Jeddah 23324, KSA",
    latitude: 21.485811,
    longitude: 39.192504
  },
  {
    name: "Albaik — Makkah Al Aziziyah",
    address: "Al Aziziyah District, Umm Al Qura Road, Makkah 24243, KSA",
    latitude: 21.422500,
    longitude: 39.826111
  },
  {
    name: "Albaik — Madinah Al Qiblatayn",
    address: "Al Qiblatayn District, King Faisal Road, Madinah 42351, KSA",
    latitude: 24.524714,
    longitude: 39.569186
  },
  {
    name: "Albaik — Riyadh Al Olaya",
    address: "Al Olaya District, Tahlia Street, Riyadh 12214, KSA",
    latitude: 24.690230,
    longitude: 46.685510
  },
  {
    name: "Albaik — Dammam Al Faisaliyah",
    address: "Al Faisaliyah District, King Fahd Road, Dammam 32272, KSA",
    latitude: 26.420389,
    longitude: 50.089811
  },
  {
    name: "Albaik — Khobar Al Rakah",
    address: "Al Rakah District, Prince Faisal bin Fahd Road, Khobar 31952, KSA",
    latitude: 26.279986,
    longitude: 50.208014
  },
  {
    name: "Albaik — Taif Al Faisaliyah",
    address: "Al Faisaliyah District, Al Faisal Road, Taif 26522, KSA",
    latitude: 21.285407,
    longitude: 40.608056
  }
]

branches = branches_data.map { |attrs| Branch.create!(attrs) }

puts "Created #{branches.count} Albaik branches"

# ───────────────────────────────────────────────
# 2. MENU ITEMS — 10 Albaik signature items
# ───────────────────────────────────────────────
puts "Creating 10 Albaik menu items..."

menu_items_data = [
  { name: "Broasted Chicken — 4 Pcs", description: "Crispy golden broasted chicken, 4 pieces with signature garlic sauce", base_availability: true },
  { name: "Broasted Chicken — 8 Pcs", description: "Family size crispy broasted chicken, 8 pieces with garlic sauce", base_availability: true },
  { name: "Fish Fillet — 2 Pcs", description: "Crispy battered fish fillet with tartar sauce", base_availability: true },
  { name: "Fish Fillet — 4 Pcs", description: "Double portion crispy fish fillet with tartar sauce", base_availability: true },
  { name: "Jumbo Shrimp — 8 Pcs", description: "Golden fried jumbo shrimp with cocktail sauce", base_availability: true },
  { name: "Chicken Fillet Sandwich", description: "Crispy chicken fillet in bun with mayo and pickles", base_availability: true },
  { name: "Family Meal — Chicken", description: "8 pcs chicken + 4 buns + large coleslaw + large fries + 4 garlic sauces", base_availability: true },
  { name: "Regular Fries", description: "Classic cut golden french fries", base_availability: true },
  { name: "Garlic Sauce Cup", description: "Albaik's signature garlic sauce", base_availability: true },
  { name: "Pepsi — Large", description: "Large chilled Pepsi", base_availability: true }
]

menu_items = menu_items_data.map { |attrs| MenuItem.create!(attrs) }

puts "Created #{menu_items.count} Albaik menu items"

# ───────────────────────────────────────────────
# 3. BRANCH MENU ITEMS — exactly 40 total (5 per branch)
# ───────────────────────────────────────────────
puts "Creating 40 branch-menu-item links..."

fixed_prices = {
  "Broasted Chicken — 4 Pcs" => 19.00,
  "Broasted Chicken — 8 Pcs" => 35.00,
  "Fish Fillet — 2 Pcs" => 15.00,
  "Fish Fillet — 4 Pcs" => 28.00,
  "Jumbo Shrimp — 8 Pcs" => 22.00,
  "Chicken Fillet Sandwich" => 14.00,
  "Family Meal — Chicken" => 55.00,
  "Regular Fries" => 6.00,
  "Garlic Sauce Cup" => 2.00,
  "Pepsi — Large" => 6.00
}

# Which 5 items each branch gets (deterministic)
branch_item_indexes = [
  [ 0, 1, 5, 7, 9 ],   # Jeddah Al Andalus
  [ 0, 2, 4, 7, 9 ],   # Jeddah Al Hamra
  [ 1, 3, 5, 7, 8 ],   # Makkah Al Aziziyah
  [ 0, 1, 6, 7, 8 ],   # Madinah Al Qiblatayn
  [ 0, 3, 4, 7, 9 ],   # Riyadh Al Olaya
  [ 1, 2, 5, 7, 8 ],   # Dammam Al Faisaliyah
  [ 0, 4, 6, 7, 9 ],   # Khobar Al Rakah
  [ 2, 3, 5, 7, 8 ]    # Taif Al Faisaliyah
]

branch_menu_items = []

branches.each_with_index do |branch, bi|
  item_indexes = branch_item_indexes[bi]

  item_indexes.each do |mi|
    item = menu_items[mi]
    price = fixed_prices[item.name]

    bmi = BranchMenuItem.create!(
      branch: branch,
      menu_item: item,
      menu_item_price: price,
      menu_item_availability: true
    )
    branch_menu_items << bmi
  end
end

puts "Created #{branch_menu_items.count} branch-menu-item links"

# ───────────────────────────────────────────────
# 4. CARTS & CART ITEMS (3 carts)
# ───────────────────────────────────────────────
puts "Creating carts..."

# Cart 1: Jeddah Al Andalus
cart1 = Cart.create!(branch: branches[0])
cart1_bmi1 = BranchMenuItem.find_by(branch: branches[0], menu_item: menu_items[0])
CartItem.create!(cart: cart1, branch_menu_item: cart1_bmi1, quantity: 1)
cart1_bmi2 = BranchMenuItem.find_by(branch: branches[0], menu_item: menu_items[5])
CartItem.create!(cart: cart1, branch_menu_item: cart1_bmi2, quantity: 2)
cart1_bmi3 = BranchMenuItem.find_by(branch: branches[0], menu_item: menu_items[7])
CartItem.create!(cart: cart1, branch_menu_item: cart1_bmi3, quantity: 1)
cart1_bmi4 = BranchMenuItem.find_by(branch: branches[0], menu_item: menu_items[9])
CartItem.create!(cart: cart1, branch_menu_item: cart1_bmi4, quantity: 2)

# Cart 2: Makkah
cart2 = Cart.create!(branch: branches[2])
cart2_bmi1 = BranchMenuItem.find_by(branch: branches[2], menu_item: menu_items[1])
CartItem.create!(cart: cart2, branch_menu_item: cart2_bmi1, quantity: 1)
cart2_bmi2 = BranchMenuItem.find_by(branch: branches[2], menu_item: menu_items[5])
CartItem.create!(cart: cart2, branch_menu_item: cart2_bmi2, quantity: 3)
cart2_bmi3 = BranchMenuItem.find_by(branch: branches[2], menu_item: menu_items[7])
CartItem.create!(cart: cart2, branch_menu_item: cart2_bmi3, quantity: 2)

# Cart 3: Riyadh
cart3 = Cart.create!(branch: branches[4])
cart3_bmi1 = BranchMenuItem.find_by(branch: branches[4], menu_item: menu_items[0])
CartItem.create!(cart: cart3, branch_menu_item: cart3_bmi1, quantity: 2)
cart3_bmi2 = BranchMenuItem.find_by(branch: branches[4], menu_item: menu_items[3])
CartItem.create!(cart: cart3, branch_menu_item: cart3_bmi2, quantity: 1)
cart3_bmi3 = BranchMenuItem.find_by(branch: branches[4], menu_item: menu_items[4])
CartItem.create!(cart: cart3, branch_menu_item: cart3_bmi3, quantity: 1)
cart3_bmi4 = BranchMenuItem.find_by(branch: branches[4], menu_item: menu_items[7])
CartItem.create!(cart: cart3, branch_menu_item: cart3_bmi4, quantity: 2)

[ cart1, cart2, cart3 ].each_with_index do |cart, i|
  puts "Cart #{i + 1}: #{cart.cart_items.count} items, total SAR #{cart.total_price.round(2)}"
end

# ───────────────────────────────────────────────
# 5. ORDERS & ORDER ITEMS — exactly 10 orders
# ───────────────────────────────────────────────
puts "Creating 10 Albaik orders..."

orders_data = [
  {
    branch: branches[0],
    type: :pickup,
    status: :completed,
    items: [
      { name: "Broasted Chicken — 4 Pcs", price: 19.00, qty: 2 },
      { name: "Regular Fries", price: 6.00, qty: 2 },
      { name: "Garlic Sauce Cup", price: 2.00, qty: 4 },
      { name: "Pepsi — Large", price: 6.00, qty: 2 }
    ]
  },
  {
    branch: branches[0],
    type: :delivery,
    status: :completed,
    items: [
      { name: "Broasted Chicken — 4 Pcs", price: 19.00, qty: 1 },
      { name: "Chicken Fillet Sandwich", price: 14.00, qty: 2 },
      { name: "Regular Fries", price: 6.00, qty: 1 },
      { name: "Pepsi — Large", price: 6.00, qty: 1 }
    ]
  },
  {
    branch: branches[1],
    type: :pickup,
    status: :preparing,
    items: [
      { name: "Broasted Chicken — 4 Pcs", price: 19.00, qty: 3 },
      { name: "Jumbo Shrimp — 8 Pcs", price: 22.00, qty: 1 },
      { name: "Regular Fries", price: 6.00, qty: 2 },
      { name: "Pepsi — Large", price: 6.00, qty: 2 }
    ]
  },
  {
    branch: branches[2],
    type: :delivery,
    status: :out_for_delivery,
    items: [
      { name: "Broasted Chicken — 8 Pcs", price: 35.00, qty: 2 },
      { name: "Regular Fries", price: 6.00, qty: 2 },
      { name: "Garlic Sauce Cup", price: 2.00, qty: 6 },
      { name: "Pepsi — Large", price: 6.00, qty: 2 }
    ]
  },
  {
    branch: branches[2],
    type: :pickup,
    status: :ready,
    items: [
      { name: "Fish Fillet — 4 Pcs", price: 28.00, qty: 1 },
      { name: "Chicken Fillet Sandwich", price: 14.00, qty: 2 },
      { name: "Regular Fries", price: 6.00, qty: 1 },
      { name: "Garlic Sauce Cup", price: 2.00, qty: 2 }
    ]
  },
  {
    branch: branches[3],
    type: :delivery,
    status: :confirmed,
    items: [
      { name: "Broasted Chicken — 4 Pcs", price: 19.00, qty: 3 },
      { name: "Regular Fries", price: 6.00, qty: 3 },
      { name: "Garlic Sauce Cup", price: 2.00, qty: 4 }
    ]
  },
  {
    branch: branches[3],
    type: :pickup,
    status: :cancelled,
    items: [
      { name: "Family Meal — Chicken", price: 55.00, qty: 1 },
      { name: "Regular Fries", price: 6.00, qty: 1 }
    ]
  },
  {
    branch: branches[4],
    type: :delivery,
    status: :pending,
    items: [
      { name: "Family Meal — Chicken", price: 55.00, qty: 1 },
      { name: "Fish Fillet — 4 Pcs", price: 28.00, qty: 1 },
      { name: "Regular Fries", price: 6.00, qty: 1 },
      { name: "Pepsi — Large", price: 6.00, qty: 2 }
    ]
  },
  {
    branch: branches[5],
    type: :pickup,
    status: :completed,
    items: [
      { name: "Broasted Chicken — 8 Pcs", price: 35.00, qty: 1 },
      { name: "Fish Fillet — 2 Pcs", price: 15.00, qty: 2 },
      { name: "Regular Fries", price: 6.00, qty: 1 },
      { name: "Garlic Sauce Cup", price: 2.00, qty: 3 }
    ]
  },
  {
    branch: branches[7],
    type: :delivery,
    status: :out_for_delivery,
    items: [
      { name: "Fish Fillet — 4 Pcs", price: 28.00, qty: 1 },
      { name: "Chicken Fillet Sandwich", price: 14.00, qty: 2 },
      { name: "Regular Fries", price: 6.00, qty: 2 },
      { name: "Garlic Sauce Cup", price: 2.00, qty: 2 },
      { name: "Pepsi — Large", price: 6.00, qty: 2 }
    ]
  }
]

orders_data.each_with_index do |order_data, i|
  order = Order.new(
    branch: order_data[:branch],
    type: order_data[:type],
    status: order_data[:status]
  )

  order_data[:items].each do |item|
    order.order_items.build(
      menu_item_name: item[:name],
      menu_item_price: item[:price],
      menu_item_quantity: item[:qty]
    )
  end

  order.total_price = order.order_items.sum { |oi| oi.menu_item_price * oi.menu_item_quantity }
  order.save!

  puts "Order #{i + 1}: #{order.order_items.count} items | #{order.type} | #{order.status} | SAR #{order.total_price.round(2)}"
end

# ───────────────────────────────────────────────
# Summary
# ───────────────────────────────────────────────
puts ""
puts "   Albaik KSA seed complete!"
puts "   Branches:          #{Branch.count}"
puts "   Menu Items:        #{MenuItem.count}"
puts "   Branch Menu Items: #{BranchMenuItem.count}"
puts "   Carts:             #{Cart.count}"
puts "   Cart Items:        #{CartItem.count}"
puts "   Orders:            #{Order.count}"
puts "   Order Items:       #{OrderItem.count}"
