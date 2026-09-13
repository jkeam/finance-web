class RetirementSalarySolver
  MAX_ITERATIONS = 60
  UPPER_BOUND_CENTS = 100_000_000_00 # $100M/yr - generous enough to always bracket a solution

  attr_reader :target_months, :fixed_spending_annual_cents, :current_net_worth_cents,
              :fixed_monthly_contribution_cents, :annual_return, :safe_withdrawal_rate, :tax_multiplier

  def initialize(target_months:, fixed_spending_annual_cents:, current_net_worth_cents:,
                  fixed_monthly_contribution_cents:, annual_return:, safe_withdrawal_rate:, tax_multiplier: 1.0)
    @target_months = target_months
    @fixed_spending_annual_cents = fixed_spending_annual_cents
    @current_net_worth_cents = current_net_worth_cents
    @fixed_monthly_contribution_cents = fixed_monthly_contribution_cents
    @annual_return = annual_return
    @safe_withdrawal_rate = safe_withdrawal_rate
    @tax_multiplier = tax_multiplier
  end

  # Finds the minimum annual salary (in cents) that reaches FI (at a fixed spending
  # level, so a fixed FI number) within target_months. Contribution capacity rises
  # with salary, so months-to-FI is monotonically non-increasing in salary - safe
  # to binary search.
  def call
    return { feasible: false, reason: :invalid_target } if target_months.nil? || target_months <= 0
    return { feasible: true, no_income_needed: true, min_annual_salary_cents: 0 } if months_to_fi(0) <= target_months

    low = 0
    high = UPPER_BOUND_CENTS
    return { feasible: false, reason: :not_achievable } if months_to_fi(high) > target_months

    MAX_ITERATIONS.times do
      break if (high - low) <= 1

      mid = (low + high) / 2
      if months_to_fi(mid) <= target_months
        high = mid
      else
        low = mid
      end
    end

    { feasible: true, no_income_needed: false, min_annual_salary_cents: high }
  end

  private

  def months_to_fi(salary_annual_cents)
    RetirementProjection.months_to_reach(
      spending_annual_cents: fixed_spending_annual_cents,
      salary_annual_cents: salary_annual_cents,
      current_net_worth_cents: current_net_worth_cents,
      fixed_monthly_contribution_cents: fixed_monthly_contribution_cents,
      annual_return: annual_return,
      safe_withdrawal_rate: safe_withdrawal_rate,
      tax_multiplier: tax_multiplier
    )
  end
end
