require "test_helper"

class BanksControllerTest < ActionDispatch::IntegrationTest
  test "should get listing" do
    get banks_url
    assert_response :success
  end
end
