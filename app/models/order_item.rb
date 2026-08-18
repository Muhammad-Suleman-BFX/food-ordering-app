class OrderItem < ApplicationRecord
  belongs_to :order

  validates :menu_item_name, presence: true, length: { maximum: 255 }
  validates :menu_item_price, presence: true, numericality: { greater_than: 0 }
  validates :menu_item_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :cannot_modify_if_order_cancelled, on: :update

  private

  def cannot_modify_if_order_cancelled
    if order.cancelled?
      errors.add(:order, "is cancelled and cannot accept new items")
    end
  end
end
