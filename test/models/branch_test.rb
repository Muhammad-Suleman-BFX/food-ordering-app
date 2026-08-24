require "test_helper"

class BranchTest < ActiveSupport::TestCase
  def setup
    @branch = Branch.new(
      name: "Albaik — Jeddah Al Andalus",
      address: "Al Andalus District, Jeddah 23326, KSA",
      latitude: 21.543333,
      longitude: 39.172778
    )
  end

  test "should be valid with all attributes" do
    assert @branch.valid?
  end

  test "should be invalid without name" do
    @branch.name = nil
    assert_not @branch.valid?
    assert_includes @branch.errors[:name], "can't be blank"
  end

  test "should be invalid without address" do
    @branch.address = nil
    assert_not @branch.valid?
    assert_includes @branch.errors[:address], "can't be blank"
  end

  test "should be invalid without latitude" do
    @branch.latitude = nil
    assert_not @branch.valid?
    assert_includes @branch.errors[:latitude], "can't be blank"
  end

  test "should be invalid without longitude" do
    @branch.longitude = nil
    assert_not @branch.valid?
    assert_includes @branch.errors[:longitude], "can't be blank"
  end

  test "should be invalid when only one coordinate is present" do
    @branch.longitude = nil
    assert_not @branch.valid?
    assert_includes @branch.errors[:base], "Latitude and longitude both must be present"
  end

  test "should be invalid with latitude out of range" do
    @branch.latitude = 91
    assert_not @branch.valid?
    assert_includes @branch.errors[:latitude], "must be less than or equal to 90"

    @branch.latitude = -91
    assert_not @branch.valid?
    assert_includes @branch.errors[:latitude], "must be greater than or equal to -90"
  end

  test "should be invalid with longitude out of range" do
    @branch.longitude = 181
    assert_not @branch.valid?
    assert_includes @branch.errors[:longitude], "must be less than or equal to 180"

    @branch.longitude = -181
    assert_not @branch.valid?
    assert_includes @branch.errors[:longitude], "must be greater than or equal to -180"
  end

  test "should be invalid with name longer than 255 characters" do
    @branch.name = "a" * 256
    assert_not @branch.valid?
    assert_includes @branch.errors[:name], "is too long (maximum is 255 characters)"
  end

  test "should be invalid with address longer than 1000 characters" do
    @branch.address = "a" * 1001
    assert_not @branch.valid?
    assert_includes @branch.errors[:address], "is too long (maximum is 1000 characters)"
  end
end
