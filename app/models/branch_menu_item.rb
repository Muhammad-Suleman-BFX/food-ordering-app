class BranchMenuItem < ApplicationRecord
  belongs_to :branch
  belongs_to :menu_item

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :availability, inclusion: { in: [ true, false ] }
  validates :menu_item_id, uniqueness: { scope: :branch_id, message: "is already associated with this branch" }
  validate :menu_item_must_be_available_if_branch_item_available

  private

  def menu_item_must_be_available_if_branch_item_available
    if availability? && menu_item.present? && !menu_item.base_availability?
      errors.add(:availability, "cannot be true when the menu item is not base available")
    end
  end
end
