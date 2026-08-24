require "test_helper"

class Api::CartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jeddah = branches(:jeddah)
    @bmi = branch_menu_items(:jeddah_chicken_4pc)
  end

  test "POST /api/carts creates a cart" do
    assert_difference "Cart.count", 1 do
      post api_carts_url, params: { cart: { branch_id: @jeddah.id, order_type: "pickup" } }
    end
    assert_response :created

    body = JSON.parse(response.body)
    assert body.key?("id")
    assert_equal @jeddah.id, body["branch_id"]
    assert_equal @jeddah.name, body["branch_name"]
    assert_equal "pickup", body["order_type"]
    assert_equal [], body["items"]
    assert_equal "0.00", body["total_price"]
    assert_equal 0, body["total_items_count"]
  end

  test "POST /api/carts returns 422 for invalid cart" do
    assert_no_difference "Cart.count" do
      post api_carts_url, params: { cart: { branch_id: nil, order_type: "pickup" } }
    end
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert body.key?("error")
    assert body.key?("details")
  end

  test "GET /api/carts/:id returns cart with items and totals" do
    cart = Cart.create!(branch: @jeddah, order_type: :pickup)
    CartItem.create!(cart: cart, branch_menu_item: @bmi, branch_menu_item_quantity: 2)

    get api_cart_url(cart)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal cart.id, body["id"]
    assert_equal @jeddah.name, body["branch_name"]
    assert_equal 1, body["items"].length
    assert_equal 2, body["items"].first["quantity"]
    assert_equal "38.00", body["total_price"]
    assert_equal 2, body["total_items_count"]
  end

  test "GET /api/carts/:id returns 404 for missing cart" do
    get api_cart_url(99999)
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_equal "Cart not found", body["error"]
  end

  test "POST /api/carts/:id/checkout creates order and destroys cart" do
    cart = Cart.create!(branch: @jeddah, order_type: :pickup)
    CartItem.create!(cart: cart, branch_menu_item: @bmi, branch_menu_item_quantity: 2)

    assert_difference "Order.count", 1 do
      assert_difference "OrderItem.count", 1 do
        post checkout_api_cart_url(cart)
      end
    end
    assert_response :created

    body = JSON.parse(response.body)
    assert body.key?("id")
    assert_equal "pickup", body["order_type"]
    assert_equal "pending", body["status"]
    assert_equal "38.00", body["total_price"]
    assert_equal 1, body["order_items"].length
    assert_equal "Broasted Chicken — 4 Pcs", body["order_items"].first["menu_item_name"]

    assert_raises(ActiveRecord::RecordNotFound) { cart.reload }
  end

  test "POST /api/carts/:id/checkout returns 422 for empty cart" do
    cart = Cart.create!(branch: @jeddah, order_type: :pickup)

    assert_no_difference "Order.count" do
      post checkout_api_cart_url(cart)
    end
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "Your cart is empty. Add items before placing an order.", body["error"]
  end

  test "POST /api/carts/:id/checkout returns 422 when item becomes unavailable" do
    cart = Cart.create!(branch: @jeddah, order_type: :pickup)
    CartItem.create!(cart: cart, branch_menu_item: @bmi, branch_menu_item_quantity: 1)
    @bmi.update!(menu_item_availability: false)

    assert_no_difference "Order.count" do
      post checkout_api_cart_url(cart)
    end
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "Some items in your cart are no longer available. Please review your cart.", body["error"]
  end
end
