require "test_helper"

class RetirementAssumptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_retirement_assumption_url
    assert_response :success
  end

  test "should update retirement assumption" do
    patch retirement_assumption_url, params: { retirement_assumption: { safe_withdrawal_rate: 0.035, expected_annual_return: 0.06, target_retirement_age: 50, birthdate: "1992-01-01" } }
    assert_redirected_to dashboard_retirement_url
    reloaded = retirement_assumptions(:one).reload
    assert_in_delta 0.035, reloaded.safe_withdrawal_rate.to_f, 0.0001
    assert_equal Date.new(1992, 1, 1), reloaded.birthdate
  end

  test "should not update with an invalid withdrawal rate" do
    patch retirement_assumption_url, params: { retirement_assumption: { safe_withdrawal_rate: 5, expected_annual_return: 0.06 } }
    assert_response :unprocessable_entity
  end
end
