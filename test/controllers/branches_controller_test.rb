require "test_helper"

class BranchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @branch = branches(:jeddah)
  end

  test "should create branch with flash notice" do
    assert_difference "Branch.count", 1 do
      post branches_path, params: {
        branch: {
          name: "Albaik — Riyadh",
          address: "Olaya, Riyadh",
          latitude: 24.7136,
          longitude: 46.6753
        }
      }
    end

    assert_redirected_to branch_path(Branch.last)
    assert_equal "Branch created.", flash[:notice]
  end

  test "should update branch with flash notice" do
    patch branch_path(@branch), params: {
      branch: { name: "Albaik — Jeddah Updated" }
    }

    assert_redirected_to branch_path(@branch)
    assert_equal "Branch updated.", flash[:notice]
    assert_equal "Albaik — Jeddah Updated", @branch.reload.name
  end

  test "should destroy branch with flash notice" do
    branch = Branch.create!(
      name: "Temporary Branch",
      address: "Test Address",
      latitude: 24.0,
      longitude: 46.0
    )

    assert_difference "Branch.count", -1 do
      delete branch_path(branch)
    end

    assert_redirected_to branches_path
    assert_equal "Branch deleted.", flash[:notice]
  end
end
