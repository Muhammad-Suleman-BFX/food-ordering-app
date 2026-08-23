require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = branches(:jeddah)
    @cart = Cart.create!(branch: @branch)
    @bmi = branch_menu_items(:jeddah_chicken_4pc)
    post order_set_branch_path, params: {
      order_type: "pickup",
      branch_id: @branch.id
    }
  end

  test "should add available item to cart" do
    assert_difference "CartItem.count", 1 do
      post cart_items_path, params: { branch_menu_item_id: @bmi.id }
    end
    assert_redirected_to current_cart_path
    assert_equal "Item added to cart.", flash[:notice]
  end

  test "should increment quantity for duplicate item" do
    post cart_items_path, params: { branch_menu_item_id: @bmi.id }
    post cart_items_path, params: { branch_menu_item_id: @bmi.id }

    cart_item = CartItem.find_by(cart: Cart.find(session[:cart_id]), branch_menu_item: @bmi)
    assert_equal 2, cart_item.branch_menu_item_quantity
  end

  test "should reject unavailable item" do
    @bmi.update!(menu_item_availability: false)
    post cart_items_path, params: { branch_menu_item_id: @bmi.id }
    assert_redirected_to current_cart_path
    assert_match /not available/, flash[:alert]
  end

  test "should reject item from different branch" do
    other_bmi = branch_menu_items(:makkah_chicken_8pc)
    post cart_items_path, params: { branch_menu_item_id: other_bmi.id }
    assert_redirected_to current_cart_path
    assert_match /not available at the selected branch/, flash[:alert]
  end

  test "should update quantity" do
    cart_item = CartItem.create!(
      cart: Cart.find(session[:cart_id]),
      branch_menu_item: @bmi,
      branch_menu_item_quantity: 1
    )
    patch cart_item_path(cart_item), params: {
      cart_item: { branch_menu_item_quantity: 3 }
    }
    assert_redirected_to current_cart_path
    assert_equal 3, cart_item.reload.branch_menu_item_quantity
  end

  test "should remove item when quantity set to zero" do
    cart_item = CartItem.create!(
      cart: Cart.find(session[:cart_id]),
      branch_menu_item: @bmi,
      branch_menu_item_quantity: 1
    )
    assert_difference "CartItem.count", -1 do
      patch cart_item_path(cart_item), params: {
        cart_item: { branch_menu_item_quantity: 0 }
      }
    end
  end

  test "should destroy cart item" do
    cart_item = CartItem.create!(
      cart: Cart.find(session[:cart_id]),
      branch_menu_item: @bmi,
      branch_menu_item_quantity: 1
    )
    assert_difference "CartItem.count", -1 do
      delete cart_item_path(cart_item)
    end
    assert_redirected_to current_cart_path
  end
end
