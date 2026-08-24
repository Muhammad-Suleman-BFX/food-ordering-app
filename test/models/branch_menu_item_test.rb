require "test_helper"

class BranchMenuItemTest < ActiveSupport::TestCase
  def setup
    @branch = branches(:makkah)
    @menu_item = menu_items(:chicken_4pc)
    @branch_menu_item = BranchMenuItem.new(
      branch: @branch,
      menu_item: @menu_item,
      menu_item_price: 19.00,
      menu_item_availability: true
    )
  end

  test "should be valid with all attributes" do
    assert @branch_menu_item.valid?
  end

  test "should be invalid without branch" do
    @branch_menu_item.branch = nil
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:branch], "must exist"
  end

  test "should be invalid without menu_item" do
    @branch_menu_item.menu_item = nil
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:menu_item], "must exist"
  end

  test "should be invalid without menu_item_price" do
    @branch_menu_item.menu_item_price = nil
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:menu_item_price], "can't be blank"
  end

  test "should be invalid with non-positive menu_item_price" do
    @branch_menu_item.menu_item_price = 0
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:menu_item_price], "must be greater than 0"

    @branch_menu_item.menu_item_price = -1
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:menu_item_price], "must be greater than 0"
  end

  test "should be invalid without menu_item_availability" do
    @branch_menu_item.menu_item_availability = nil
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:menu_item_availability], "is not included in the list"
  end

  test "should be invalid when menu_item_availability is true but base_availability is false" do
    @menu_item.update!(base_availability: false)
    assert_not @branch_menu_item.valid?
    assert_includes @branch_menu_item.errors[:menu_item_availability], "cannot be true when the menu item is not available at base level"
  end

  test "should be valid with false menu_item_availability when base_availability is false" do
    @menu_item.update!(base_availability: false)
    @branch_menu_item.menu_item_availability = false
    assert @branch_menu_item.valid?
  end

  test "should enforce uniqueness of menu_item per branch" do
    @branch_menu_item.save!
    duplicate = BranchMenuItem.new(
      branch: @branch,
      menu_item: @menu_item,
      menu_item_price: 19.00,
      menu_item_availability: true
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:menu_item_id], "is already associated with this branch"
  end

  test "should allow same menu_item in different branches" do
    menu_item = MenuItem.create!(name: "Fish Burger", base_availability: true)
    BranchMenuItem.create!(
      branch: branches(:jeddah),
      menu_item: menu_item,
      menu_item_price: 10.00,
      menu_item_availability: true
    )
    duplicate = BranchMenuItem.new(
      branch: @branch,
      menu_item: menu_item,
      menu_item_price: 10.00,
      menu_item_availability: true
    )
    assert duplicate.valid?
  end

  test "should not destroy when cart_items exist" do
    @branch_menu_item.save!
    cart = Cart.create!(branch: @branch)
    CartItem.create!(cart: cart, branch_menu_item: @branch_menu_item, branch_menu_item_quantity: 1)

    assert_no_difference "BranchMenuItem.count" do
      @branch_menu_item.destroy
    end
  end

  test "is_available_at_branch? should return menu_item_availability" do
    assert @branch_menu_item.is_available_at_branch?

    @branch_menu_item.menu_item_availability = false
    assert_not @branch_menu_item.is_available_at_branch?
  end

  test "effective_available? should require both base and branch availability" do
    assert @branch_menu_item.effective_available?

    @branch_menu_item.menu_item_availability = false
    assert_not @branch_menu_item.effective_available?

    @branch_menu_item.menu_item_availability = true
    @menu_item.update!(base_availability: false)
    assert_not @branch_menu_item.effective_available?
  end

  test "available scope should return only items available at branch and base level" do
    @branch_menu_item.save!
    unavailable_base_item = MenuItem.create!(name: "Secret Item", base_availability: false)
    unavailable_bmi = BranchMenuItem.create!(
      branch: @branch,
      menu_item: unavailable_base_item,
      menu_item_price: 1.00,
      menu_item_availability: false
    )

    available = BranchMenuItem.available
    assert_includes available, @branch_menu_item
    assert_includes available, branch_menu_items(:makkah_chicken_8pc)
    assert_not_includes available, unavailable_bmi
  end

  test "by_branch scope should filter items by branch" do
    result = BranchMenuItem.by_branch(branches(:makkah))
    assert_includes result, branch_menu_items(:makkah_chicken_8pc)
    assert_not_includes result, branch_menu_items(:jeddah_chicken_4pc)
  end

  test "ordered_by_price scope should order by price ascending" do
    prices = BranchMenuItem.ordered_by_price.map(&:menu_item_price)
    assert_equal prices.sort, prices
  end
end
