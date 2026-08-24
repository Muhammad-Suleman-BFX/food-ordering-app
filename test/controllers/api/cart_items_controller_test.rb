require "test_helper"

class Api::CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jeddah = branches(:jeddah)
    @makkah = branches(:makkah)
    @bmi = branch_menu_items(:jeddah_chicken_4pc)
    @other_bmi = branch_menu_items(:makkah_chicken_8pc)
    @cart = Cart.create!(branch: @jeddah, order_type: :pickup)
  end

  test "POST /api/carts/:id/items adds item to cart" do
    assert_difference "CartItem.count", 1 do
      post api_cart_items_url(@cart), params: { branch_menu_item_id: @bmi.id }
    end
    assert_response :created

    body = JSON.parse(response.body)
    assert_equal @bmi.id, body["branch_menu_item_id"]
    assert_equal 1, body["quantity"]
    assert_equal "Broasted Chicken — 4 Pcs", body["name"]
  end

  test "POST /api/carts/:id/items increments quantity for duplicate item" do
    post api_cart_items_url(@cart), params: { branch_menu_item_id: @bmi.id }
    post api_cart_items_url(@cart), params: { branch_menu_item_id: @bmi.id }

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal 2, body["quantity"]
    assert_equal 1, @cart.cart_items.count
  end

  test "POST /api/carts/:id/items returns 422 for unavailable item" do
    @bmi.update!(menu_item_availability: false)

    assert_no_difference "CartItem.count" do
      post api_cart_items_url(@cart), params: { branch_menu_item_id: @bmi.id }
    end
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "This item is not available.", body["error"]
  end

  test "POST /api/carts/:id/items returns 422 for item from different branch" do
    assert_no_difference "CartItem.count" do
      post api_cart_items_url(@cart), params: { branch_menu_item_id: @other_bmi.id }
    end
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "This item is not available at the selected branch.", body["error"]
  end

  test "POST /api/carts/:id/items returns 404 for missing cart" do
    post api_cart_items_url(99999), params: { branch_menu_item_id: @bmi.id }
    assert_response :not_found
  end

  test "PATCH /api/carts/:id/items/:item_id updates quantity" do
    cart_item = CartItem.create!(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)

    patch api_cart_item_url(@cart, cart_item), params: { quantity: 3 }
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 3, body["quantity"]
    assert_equal 3, cart_item.reload.branch_menu_item_quantity
  end

  test "PATCH /api/carts/:id/items/:item_id returns 422 for quantity <= 0" do
    cart_item = CartItem.create!(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)

    patch api_cart_item_url(@cart, cart_item), params: { quantity: 0 }
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "Quantity must be greater than 0. Use DELETE to remove the item.", body["error"]
  end

  test "DELETE /api/carts/:id/items/:item_id removes item" do
    cart_item = CartItem.create!(cart: @cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)

    assert_difference "CartItem.count", -1 do
      delete api_cart_item_url(@cart, cart_item)
    end
    assert_response :no_content
  end

  test "DELETE /api/carts/:id/items/:item_id returns 404 for item not in cart" do
    other_cart = Cart.create!(branch: @makkah, order_type: :delivery)
    cart_item = CartItem.create!(cart: other_cart, branch_menu_item: @other_bmi, branch_menu_item_quantity: 1)

    delete api_cart_item_url(@cart, cart_item)
    assert_response :not_found
  end
end
