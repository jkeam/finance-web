require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get listing" do
    get transactions_url
    assert_response :success
  end
end
