require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @branch = branches(:jeddah)
    @order = Order.new(
      branch: @branch,
      order_type: :pickup,
      status: :pending,
      total_price: 19.00
    )
  end

  test "should be valid with all attributes" do
    @order.order_items.build(
      menu_item_name: "Chicken",
      menu_item_price: 19.00,
      menu_item_quantity: 1
    )
    assert @order.valid?
  end

  test "should reject empty order" do
    @order.total_price = 0
    assert_not @order.valid?
    assert_includes @order.errors[:base], "Order must contain at least one item"
  end

  test "should reject negative total_price" do
    @order.total_price = -5
    @order.order_items.build(menu_item_name: "X", menu_item_price: 1, menu_item_quantity: 1)
    assert_not @order.valid?
  end

  test "should snapshot order item prices" do
    bmi = branch_menu_items(:jeddah_chicken_4pc)
    @order.order_items.build(
      menu_item_name: bmi.menu_item.name,
      menu_item_price: bmi.menu_item_price,
      menu_item_quantity: 1
    )
    @order.total_price = bmi.menu_item_price

    # Change the branch menu item price after order creation
    bmi.update!(menu_item_price: 99.00)

    # Order item price should NOT change
    assert_equal 19.00, @order.order_items.first.menu_item_price
  end
end
