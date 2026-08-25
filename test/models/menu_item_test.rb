require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  def setup
    @menu_item = MenuItem.new(
      name: "Broasted Chicken — 4 Pcs",
      description: "Crispy golden broasted chicken",
      base_availability: true
    )
  end

  test "should be valid with all attributes" do
    assert @menu_item.valid?
  end

  test "should be invalid without name" do
    @menu_item.name = nil
    assert_not @menu_item.valid?
    assert_includes @menu_item.errors[:name], "can't be blank"
  end

  test "should be invalid with name longer than 255 characters" do
    @menu_item.name = "a" * 256
    assert_not @menu_item.valid?
    assert_includes @menu_item.errors[:name], "is too long (maximum is 255 characters)"
  end

  test "should be invalid with description longer than 2000 characters" do
    @menu_item.description = "a" * 2001
    assert_not @menu_item.valid?
    assert_includes @menu_item.errors[:description], "is too long (maximum is 2000 characters)"
  end

  test "should be valid without description" do
    @menu_item.description = nil
    assert @menu_item.valid?
  end

  test "should be invalid without base_availability" do
    @menu_item.base_availability = nil
    assert_not @menu_item.valid?
    assert_includes @menu_item.errors[:base_availability], "is not included in the list"
  end

  test "should be valid when base_availability is false" do
    @menu_item.base_availability = false
    assert @menu_item.valid?
  end

  test "should not destroy associated branch_menu_items if menu_item linked with branch" do
    menu_item = menu_items(:chicken_4pc)
    assert_difference "BranchMenuItem.count", 0 do
      menu_item.destroy
    end
  end

  test "should have many branch_menu_items" do
    menu_item = menu_items(:chicken_8pc)
    assert_equal 2, menu_item.branch_menu_items.count
    assert_includes menu_item.branch_menu_items.map(&:branch), branches(:jeddah)
    assert_includes menu_item.branch_menu_items.map(&:branch), branches(:makkah)
  end

  test "should have many branches through branch_menu_items" do
    menu_item = menu_items(:chicken_8pc)
    assert_equal 2, menu_item.branches.count
    assert_includes menu_item.branches, branches(:jeddah)
    assert_includes menu_item.branches, branches(:makkah)
  end
end
