require "test_helper"

class Api::BranchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jeddah = branches(:jeddah)
    @makkah = branches(:makkah)
  end

  test "GET /api/branches returns all branches as JSON" do
    get api_branches_url
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 2, body.length
    assert_equal @jeddah.name, body.first["name"]
    assert body.first.key?("id")
    assert body.first.key?("address")
    assert body.first.key?("latitude")
    assert body.first.key?("longitude")
  end

  test "GET /api/branches/nearest returns nearest branch" do
    get nearest_api_branches_url, params: { latitude: 21.5, longitude: 39.2 }
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @jeddah.id, body["id"]
  end

  test "GET /api/branches/nearest returns 400 when coordinates missing" do
    get nearest_api_branches_url
    assert_response :bad_request

    body = JSON.parse(response.body)
    assert_equal "Both latitude and longitude are required", body["error"]
  end

  test "GET /api/branches/:id/menu returns available items with branch price" do
    get menu_api_branch_url(@jeddah)
    assert_response :success

    body = JSON.parse(response.body)
    assert body.any?
    item = body.first
    assert item.key?("id")
    assert item.key?("menu_item_id")
    assert item.key?("name")
    assert item.key?("price")
    assert item.key?("available")
  end

  test "GET /api/branches/:id/menu returns 404 for missing branch" do
    get menu_api_branch_url(99999)
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_equal "Branch not found", body["error"]
  end
end
