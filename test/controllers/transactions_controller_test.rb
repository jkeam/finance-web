require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get listing" do
    get transactions_url
    assert_response :success
  end

  test "should get show" do
    get transaction_url(transactions(:one))
    assert_response :success
  end
end
