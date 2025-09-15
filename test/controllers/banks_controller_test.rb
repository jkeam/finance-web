require "test_helper"

class BanksControllerTest < ActionDispatch::IntegrationTest
  test "should get listing" do
    get banks_url
    assert_response :success
  end

  test "should get show" do
    get bank_url(banks(:one))
    assert_response :success
  end
end
