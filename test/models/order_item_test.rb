require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  def setup
    @order = Order.new(
      branch: branches(:jeddah),
      order_type: :pickup,
      status: :pending,
      total_price: 19.00
    )
    @order_item = @order.order_items.build(
      menu_item_name: "Broasted Chicken — 4 Pcs",
      menu_item_price: 19.00,
      menu_item_quantity: 1
    )
  end

  test "should be valid with all attributes" do
    assert @order.valid?
    assert @order_item.valid?
  end

  test "should be invalid without menu_item_name" do
    @order_item.menu_item_name = nil
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_name], "can't be blank"
  end

  test "should be invalid with menu_item_name longer than 255 characters" do
    @order_item.menu_item_name = "a" * 256
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_name], "is too long (maximum is 255 characters)"
  end

  test "should be invalid without menu_item_price" do
    @order_item.menu_item_price = nil
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_price], "can't be blank"
  end

  test "should be invalid with non-positive menu_item_price" do
    @order_item.menu_item_price = 0
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_price], "must be greater than 0"

    @order_item.menu_item_price = -1
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_price], "must be greater than 0"
  end

  test "should be invalid without menu_item_quantity" do
    @order_item.menu_item_quantity = nil
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_quantity], "can't be blank"
  end

  test "should be invalid with non-integer menu_item_quantity" do
    @order_item.menu_item_quantity = 1.5
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_quantity], "must be an integer"
  end

  test "should be invalid with non-positive menu_item_quantity" do
    @order_item.menu_item_quantity = 0
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_quantity], "must be greater than 0"

    @order_item.menu_item_quantity = -1
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:menu_item_quantity], "must be greater than 0"
  end

  test "should be invalid when order is cancelled on update" do
    @order.status = :cancelled
    @order.save!
    assert_not @order_item.update(menu_item_quantity: 2)
    assert_includes @order_item.errors[:order], "is cancelled and cannot accept new items"
  end

  test "should allow update when order is not cancelled" do
    assert @order_item.update(menu_item_quantity: 2)
    assert_equal 2, @order_item.menu_item_quantity
  end

  test "should destroy order_items when order is destroyed" do
    @order.save!
    assert_difference "OrderItem.count", -1 do
      @order.destroy
    end
  end
end
