class Order < ApplicationRecord
  belongs_to :branch
  has_many :order_items, dependent: :destroy

  enum order_type: { pickup: 0, delivery: 1 }
  enum status: {
    pending: 0,
    confirmed: 1,
    preparing: 2,
    ready: 3,
    out_for_delivery: 4,
    completed: 5,
    cancelled: 6
  }

  validates :branch_id, presence: true
  validates :order_type, presence: true, inclusion: { in: order_types.keys }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  validate :must_have_at_least_one_item, on: :create
  validate :cannot_modify_if_cancelled, on: :update
end
