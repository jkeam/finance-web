require "application_system_test_case"

class BudgetsTest < ApplicationSystemTestCase
  setup do
    @budget = budgets(:one)
  end

  test "visiting the index" do
    visit budgets_url
    assert_selector "h1", text: "Listing"
  end

  test "should create budget" do
    visit budgets_url
    click_on "New budget"

    fill_in "Name", with: "New Budget"
    click_on "Submit"

    assert_text "Budget was successfully created"
    click_on "Listing"
  end

  test "should update Budget" do
    visit budget_url(@budget)
    click_on "Edit"

    fill_in "Name", with: "Updated Budget"
    click_on "Submit"

    assert_text "Budget was successfully updated"
    click_on "Listing"
  end

  test "should destroy Budget" do
    visit budget_url(@budget)
    click_on "Destroy this budget", match: :first

    assert_text "Budget was successfully destroyed"
  end
end
