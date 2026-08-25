class MenuItem < ApplicationRecord
  has_many :branch_menu_items, dependent: :restrict_with_error
  has_many :branches, through: :branch_menu_items

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 2000 }
  validates :base_availability, inclusion: { in: [ true, false ] }
end
