require "test_helper"

class OrderingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @branch = branches(:jeddah)
    @bmi = branch_menu_items(:jeddah_chicken_4pc)
  end

  test "complete ordering flow: start → cart → order" do
    # 1. Start order
    get order_start_path
    assert_response :success

    post order_set_branch_path, params: {
      order_type: "pickup",
      branch_id: @branch.id
    }
    assert_redirected_to menu_branch_path(@branch)
    cart_id = session[:cart_id]
    assert cart_id.present?

    # 2. Add item to cart
    post cart_items_path, params: { branch_menu_item_id: @bmi.id }
    assert_redirected_to current_cart_path

    # 3. View cart
    get current_cart_path
    assert_response :success
    assert_select ".list-primary", @bmi.menu_item.name

    # 4. Place order
    assert_difference "Order.count", 1 do
      assert_difference "OrderItem.count", 1 do
        post place_order_path
      end
    end

    # 5. Verify order confirmation
    order = Order.last
    assert_redirected_to order_path(order)
    follow_redirect!
    assert_select "h1", "Order Confirmed"
    assert_select ".list-primary", @bmi.menu_item.name

    # 6. Verify cart was cleared
    assert_nil session[:cart_id]
    assert_nil session[:order_type]

    # 7. Verify price snapshot
    assert_equal @bmi.menu_item_price, order.order_items.first.menu_item_price
  end

  test "cannot place order with empty cart" do
    post order_set_branch_path, params: {
      order_type: "pickup",
      branch_id: @branch.id
    }

    post place_order_path
    assert_redirected_to current_cart_path
    assert_equal "Your cart is empty. Add items before placing an order.", flash[:alert]
  end

  test "unavailable item cannot be added to cart" do
    @bmi.update!(menu_item_availability: false)

    post order_set_branch_path, params: {
      order_type: "pickup",
      branch_id: @branch.id
    }

    assert_no_difference "CartItem.count" do
      post cart_items_path, params: { branch_menu_item_id: @bmi.id }
    end
    assert_match /not available/, flash[:alert]
  end
end
