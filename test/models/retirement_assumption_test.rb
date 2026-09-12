require "test_helper"

class RetirementAssumptionTest < ActiveSupport::TestCase
  test "current returns existing row when present" do
    assumption = RetirementAssumption.current
    assert_equal retirement_assumptions(:one).id, assumption.id
  end

  test "current builds a default row when none exists" do
    RetirementAssumption.delete_all
    assumption = RetirementAssumption.current
    refute assumption.persisted?
    assert_nil assumption.id
  end

  test "requires a safe withdrawal rate between 0 and 1" do
    assumption = RetirementAssumption.new(safe_withdrawal_rate: 1.5, expected_annual_return: 0.07)
    refute assumption.valid?
  end

  test "age_on returns nil without a birthdate" do
    assumption = RetirementAssumption.new(birthdate: nil)
    assert_nil assumption.age_on(Date.new(2050, 1, 1))
  end

  test "age_on computes age as of a future date, accounting for the birthday not yet occurring" do
    assumption = RetirementAssumption.new(birthdate: Date.new(1990, 6, 15))
    assert_equal 60, assumption.age_on(Date.new(2050, 6, 15))
    assert_equal 59, assumption.age_on(Date.new(2050, 6, 14))
    assert_equal 60, assumption.age_on(Date.new(2050, 12, 1))
  end
end
