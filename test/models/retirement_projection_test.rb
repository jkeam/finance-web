require "test_helper"

class RetirementProjectionTest < ActiveSupport::TestCase
  test "reaches target with growth and contributions" do
    result = RetirementProjection.new(
      fi_number: 1_000_000,
      current_net_worth: 500_000,
      monthly_contribution: 2_000,
      annual_return: 0.07
    ).call

    assert result[:reached]
    assert result[:months] > 0
    assert result[:target_date] > Date.current
  end

  test "already at or above the fi number reaches immediately" do
    result = RetirementProjection.new(
      fi_number: 100_000,
      current_net_worth: 150_000,
      monthly_contribution: 0,
      annual_return: 0.07
    ).call

    assert result[:reached]
    assert_equal 0, result[:months]
  end

  test "never reaches target within the cap when contributions and growth are zero" do
    result = RetirementProjection.new(
      fi_number: 1_000_000,
      current_net_worth: 0,
      monthly_contribution: 0,
      annual_return: 0
    ).call

    refute result[:reached]
    assert_nil result[:months]
    assert_nil result[:target_date]
    assert_equal RetirementProjection::MAX_MONTHS + 1, result[:monthly_series].size
  end

  test "sensitivity grid varies months to target across rates and contributions" do
    grid = RetirementProjection.sensitivity_grid(
      fi_number: 1_000_000,
      current_net_worth: 200_000,
      monthly_contribution: 2_000
    )

    assert_equal RetirementProjection::DEFAULT_RETURN_RATES.size, grid.size
    grid.each do |row|
      assert_equal RetirementProjection::DEFAULT_CONTRIBUTION_DELTAS.size, row[:results].size
    end

    fastest = grid.last[:results].last[:months]
    slowest = grid.first[:results].first[:months]
    assert fastest < slowest
  end
end
