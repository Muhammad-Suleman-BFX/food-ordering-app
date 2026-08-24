require "test_helper"

class ApiOrderingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @jeddah = branches(:jeddah)
    @makkah = branches(:makkah)
    @bmi = branch_menu_items(:jeddah_chicken_4pc)
  end

  test "pickup flow: create cart → add item → update → checkout" do
    post api_carts_url, params: { cart: { branch_id: @jeddah.id, order_type: "pickup" } }
    assert_response :created
    cart = JSON.parse(response.body)
    cart_id = cart["id"]

    get menu_api_branch_url(@jeddah)
    assert_response :success
    menu = JSON.parse(response.body)
    assert menu.any? { |item| item["id"] == @bmi.id && item["price"] == "19.00" }

    post api_cart_items_url(cart_id), params: { branch_menu_item_id: @bmi.id }
    assert_response :created

    item = JSON.parse(response.body)
    patch api_cart_item_url(cart_id, item["id"]), params: { quantity: 2 }
    assert_response :success

    get api_cart_url(cart_id)
    assert_response :success
    cart = JSON.parse(response.body)
    assert_equal "38.00", cart["total_price"]
    assert_equal 2, cart["total_items_count"]
    assert_equal @jeddah.name, cart["branch_name"]

    assert_difference "Order.count", 1 do
      post checkout_api_cart_url(cart_id)
    end
    assert_response :created

    order = JSON.parse(response.body)
    assert_equal "pickup", order["order_type"]
    assert_equal "pending", order["status"]
    assert_equal "38.00", order["total_price"]
    assert_equal "Broasted Chicken — 4 Pcs", order["order_items"].first["menu_item_name"]
    assert_equal "19.00", order["order_items"].first["menu_item_price"]
  end

  test "delivery flow: nearest branch → cart → checkout" do
    get nearest_api_branches_url, params: { latitude: 21.5, longitude: 39.2 }
    assert_response :success
    nearest = JSON.parse(response.body)
    assert_equal @jeddah.id, nearest["id"]

    post api_carts_url, params: { cart: { branch_id: nearest["id"], order_type: "delivery" } }
    assert_response :created
    cart_id = JSON.parse(response.body)["id"]

    post api_cart_items_url(cart_id), params: { branch_menu_item_id: @bmi.id }
    assert_response :created

    post checkout_api_cart_url(cart_id)
    assert_response :created

    order = JSON.parse(response.body)
    assert_equal "delivery", order["order_type"]
    assert_equal @jeddah.id, order["branch_id"]
  end

  test "delivery nearest prefers makkah for makkah coordinates" do
    get nearest_api_branches_url, params: { latitude: 21.42, longitude: 39.83 }
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @makkah.id, body["id"]
  end
end
