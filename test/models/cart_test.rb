require "test_helper"

class CartTest < ActiveSupport::TestCase
  def setup
    @branch = branches(:jeddah)
    @cart = Cart.create!(branch: @branch)
  end

  test "should be valid with branch" do
    assert @cart.valid?
  end

  test "should be invalid without branch" do
    cart = Cart.new(branch: nil)
    assert_not cart.valid?
  end

  test "total_price sums cart items correctly" do
    menu_item = menu_items(:chicken_4pc)
    bmi = branch_menu_items(:jeddah_chicken_4pc)
    CartItem.create!(cart: @cart, branch_menu_item: bmi, branch_menu_item_quantity: 2)

    assert_equal 38.00, @cart.total_price
  end

  test "total_items_count sums quantities" do
    bmi = branch_menu_items(:jeddah_chicken_4pc)
    CartItem.create!(cart: @cart, branch_menu_item: bmi, branch_menu_item_quantity: 3)

    assert_equal 3, @cart.total_items_count
  end
end
