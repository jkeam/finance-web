require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @budget = budgets(:one)
  end

  test "should get index" do
    get budgets_url
    assert_response :success
  end

  test "should get new" do
    get new_budget_url
    assert_response :success
  end

  test "should create budget" do
    assert_difference("Budget.count") do
      # post budgets_url, params: { budget: { amount: @budget.amount, name: @budget.name, transaction_category: @budget.transaction_category } }
      post budgets_url, params: { budget: { name: @budget.name } }
    end

    assert_redirected_to budget_url(Budget.last)
  end

  test "should show budget" do
    get budget_url(@budget)
    assert_response :success
  end

  test "show displays income summary tiles and rows" do
    get budget_url(@budget)
    assert_response :success

    assert_select "nav.level .heading", text: "Budget Total"
    assert_select "nav.level .heading", text: "Avg Income"
    assert_select "nav.level .heading", text: "Avg Left Over"
    assert_select "tr.budget-summary-row td strong", text: "Income"
    assert_select "tr.budget-summary-row td strong", text: "Left Over"
    assert_select "h2.subtitle", text: "Income vs. Spending"
  end

  test "show colors left over red when negative and green otherwise" do
    get budget_url(@budget)

    # Left Over tile and table cells use exactly one of the two sign colors
    assert_select "nav.level p.title.has-text-danger, nav.level p.title.has-text-success", count: 1
    assert_select "tr.budget-summary-row:last-child td.has-text-danger, tr.budget-summary-row:last-child td.has-text-success", count: 4
  end

  test "should get edit" do
    get edit_budget_url(@budget)
    assert_response :success
  end

  test "should update budget" do
    # patch budget_url(@budget), params: { budget: { amount: @budget.amount, name: @budget.name, transaction_category: @budget.transaction_category } }
    patch budget_url(@budget), params: { budget: { name: @budget.name } }
    assert_redirected_to budget_url(@budget)
  end

  test "should destroy budget" do
    assert_difference("Budget.count", -1) do
      delete budget_url(@budget)
    end

    assert_redirected_to budgets_url
  end
end
