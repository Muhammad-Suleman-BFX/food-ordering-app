require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = branches(:jeddah)
    @order = Order.new(
      branch: @branch,
      order_type: :pickup,
      status: :pending,
      total_price: 19.00
    )
    @order.order_items.build(
      menu_item_name: "Broasted Chicken — 4 Pcs",
      menu_item_price: 19.00,
      menu_item_quantity: 1
    )
    @order.save!
  end

  test "should get index" do
    get orders_path
    assert_response :success
  end

  test "should show order" do
    get order_path(@order)
    assert_response :success
  end
end
