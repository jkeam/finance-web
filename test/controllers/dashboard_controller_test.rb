require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_index_url
    assert_response :success
  end

  test "should get spending" do
    get dashboard_spending_url
    assert_response :success
  end

  test "should get monthly spending" do
    get dashboard_monthly_url
    assert_response :success
  end

  test "should get trends spending" do
    get dashboard_trends_url
    assert_response :success
  end
end
