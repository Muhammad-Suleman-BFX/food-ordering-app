class BranchMenuItem < ApplicationRecord
  belongs_to :branch
  belongs_to :menu_item

  validates :menu_item_price, presence: true, numericality: { greater_than: 0 }
  validates :menu_item_availability, inclusion: { in: [ true, false ] }
  validates :menu_item_id, uniqueness: { scope: :branch_id, message: "is already associated with this branch" }
  validate :menu_item_must_be_available_if_branch_item_available

  scope :available, -> { where(menu_item_availability: true).joins(:menu_item).where(menu_items: { base_availability: true }) }
  scope :by_branch, ->(branch_id) { where(branch_id: branch_id) }
  scope :ordered_by_price, -> { order(menu_item_price: :asc) }

  private

  def menu_item_must_be_available_if_branch_item_available
    if menu_item_availability? && menu_item.present? && !menu_item.base_availability?
      errors.add(:menu_item_availability, "cannot be true when the menu item is not base available")
    end
  end
end
