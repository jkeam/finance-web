class RetirementSpendingSolver
  MAX_ITERATIONS = 60

  attr_reader :target_months, :target_annual_income_cents, :current_net_worth_cents,
              :fixed_monthly_contribution_cents, :annual_return, :safe_withdrawal_rate, :tax_multiplier

  def initialize(target_months:, target_annual_income_cents:, current_net_worth_cents:,
                  fixed_monthly_contribution_cents:, annual_return:, safe_withdrawal_rate:, tax_multiplier: 1.0)
    @target_months = target_months
    @target_annual_income_cents = target_annual_income_cents
    @current_net_worth_cents = current_net_worth_cents
    @fixed_monthly_contribution_cents = fixed_monthly_contribution_cents
    @annual_return = annual_return
    @safe_withdrawal_rate = safe_withdrawal_rate
    @tax_multiplier = tax_multiplier
  end

  # Finds the maximum annual spending (in cents) that still reaches the FI number
  # implied by that spending within target_months, given a fixed target income.
  # Spending and the resulting FI number move together, and contribution capacity
  # (income - spending) moves opposite them, so months-to-FI is monotonic in spending -
  # safe to binary search.
  def call
    return { feasible: false, reason: :invalid_target } if target_months.nil? || target_months <= 0

    low = 0
    high = target_annual_income_cents

    return { feasible: false, reason: :not_achievable } if months_to_fi(low) > target_months
    return { feasible: true, unconstrained: true, max_annual_spending_cents: high } if months_to_fi(high) <= target_months

    MAX_ITERATIONS.times do
      break if (high - low) <= 1

      mid = (low + high) / 2
      if months_to_fi(mid) <= target_months
        low = mid
      else
        high = mid
      end
    end

    { feasible: true, unconstrained: false, max_annual_spending_cents: low }
  end

  private

  def months_to_fi(spending_annual_cents)
    RetirementProjection.months_to_reach(
      spending_annual_cents: spending_annual_cents,
      salary_annual_cents: target_annual_income_cents,
      current_net_worth_cents: current_net_worth_cents,
      fixed_monthly_contribution_cents: fixed_monthly_contribution_cents,
      annual_return: annual_return,
      safe_withdrawal_rate: safe_withdrawal_rate,
      tax_multiplier: tax_multiplier
    )
  end
end
