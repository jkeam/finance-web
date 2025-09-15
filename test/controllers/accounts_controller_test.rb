require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get accounts_url
    assert_response :success
  end

  test "should get show" do
    get account_url(accounts(:one))
    assert_response :success
  end
end
