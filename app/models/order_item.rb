class OrderItem < ApplicationRecord
  belongs_to :order

  validates :item_name, presence: true, length: { maximum: 255 }
  validates :item_price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :order_must_not_be_cancelled, on: :create
end
