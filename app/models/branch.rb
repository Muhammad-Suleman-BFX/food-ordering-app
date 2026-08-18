class Branch < ApplicationRecord
  has_many :branch_menu_items, dependent: :destroy
  has_many :menu_items, through: :branch_menu_items
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :address, presence: true, length: { maximum: 1000 }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validate :coordinates_must_be_both_present

  private

  def coordinates_must_be_both_present
    if latitude.blank? || longitude.blank?
      errors.add(:base, "Latitude and longitude both must be present")
    end
  end
end
