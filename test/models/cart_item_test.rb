require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  def setup
    @cart = carts(:one)
    @bmi = branch_menu_items(:jeddah_chicken_4pc)
  end

  test "should be valid with available item" do
    item = CartItem.new(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)
    assert item.valid?
  end

  test "should reject unavailable item" do
    @bmi.update!(menu_item_availability: false)
    item = CartItem.new(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)
    assert_not item.valid?
    assert_includes item.errors[:branch_menu_item], "is not available for order"
  end

  test "should reject item from different branch" do
    other_branch_bmi = branch_menu_items(:makkah_chicken_8pc)
    item = CartItem.new(cart: @cart, branch_menu_item: other_branch_bmi, branch_menu_item_quantity: 1)
    assert_not item.valid?
  end

  test "should require positive integer quantity" do
    item = CartItem.new(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 0)
    assert_not item.valid?

    item.branch_menu_item_quantity = -1
    assert_not item.valid?
  end

  test "should enforce uniqueness of branch_menu_item per cart" do
    CartItem.create!(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)
    duplicate = CartItem.new(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)
    assert_not duplicate.valid?
  end
end
