require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = branches(:jeddah)
  end

  test "should get start page" do
    get order_start_path
    assert_response :success
    assert_select "h1", "Start Your Order"
  end

  test "should redirect to menu on valid start submission" do
    post order_set_branch_path, params: {
      order_type: "pickup",
      branch_id: @branch.id
    }
    assert_redirected_to menu_branch_path(@branch)
    assert_equal "Cart started. Browse the menu and add items.", flash[:notice]
    assert session[:cart_id].present?
    assert_equal "pickup", session[:order_type]
  end

  test "should render start with alert when order_type is missing" do
    post order_set_branch_path, params: {
      order_type: "",
      branch_id: @branch.id
    }
    assert_response :unprocessable_entity
    assert_select ".flash-alert", /Please select an order type/
  end

  test "should render start with alert when neither branch nor gps provided" do
    post order_set_branch_path, params: {
      order_type: "delivery",
      branch_id: "",
      latitude: "",
      longitude: ""
    }
    assert_response :unprocessable_entity
    assert_select ".flash-alert", /Please select a branch or enter both latitude and longitude/
  end

  test "should persist form data on validation failure" do
    post order_set_branch_path, params: {
      order_type: "delivery",
      branch_id: "",
      latitude: "",
      longitude: ""
    }
    assert_response :unprocessable_entity
    # Check that delivery radio is still checked
    assert_select "input[type=radio][value=delivery][checked=checked]"
  end
end
