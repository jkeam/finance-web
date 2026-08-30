require "test_helper"

class BalancesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_balance_url
    assert_response :success
  end

  test "should create balance" do
    assert_difference("Balance.count") do
      post balances_url, params: { balance: { account_id: accounts(:five).id, date: Date.current, amount: 1000 } }
    end

    assert_redirected_to dashboard_retirement_url
  end

  test "should not create balance without an account" do
    assert_no_difference("Balance.count") do
      post balances_url, params: { balance: { date: Date.current, amount: 1000 } }
    end

    assert_response :unprocessable_entity
  end
end
