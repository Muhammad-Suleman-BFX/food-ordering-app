class Cart < ApplicationRecord
  belongs_to :branch
  has_many :cart_items, dependent: :destroy
  has_many :branch_menu_items, through: :cart_items

  validates :branch_id, presence: true
  validate :all_items_must_belong_to_same_branch

  def total_price
    cart_items.includes(:branch_menu_item).sum do |item|
      item.branch_menu_item.menu_item_price * item.branch_menu_item_quantity
    end
  end

  def total_items_count
    cart_items.sum(:branch_menu_item_quantity)
  end

  private

  def all_items_must_belong_to_same_branch
    cart_items.each do |cart_item|
      if cart_item.branch_menu_item.branch_id != branch_id
        errors.add(:base, "All cart items must belong to the same branch")
        break
      end
    end
  end
end
