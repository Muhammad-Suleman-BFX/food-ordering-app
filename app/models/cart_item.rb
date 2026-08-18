class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :branch_menu_item

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :branch_menu_item_id, uniqueness: { scope: :cart_id, message: "is already in the cart" }
  validate :branch_menu_item_must_be_available
  validate :must_belong_to_same_branch_as_cart
end
