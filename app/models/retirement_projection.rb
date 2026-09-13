class RetirementProjection
  MAX_MONTHS = 600 # 50 years

  DEFAULT_RETURN_RATES = [ 0.04, 0.06, 0.08, 0.10 ].freeze
  DEFAULT_CONTRIBUTION_DELTAS = [ -0.2, 0, 0.2 ].freeze

  attr_reader :fi_number, :current_net_worth, :monthly_contribution, :annual_return

  def initialize(fi_number:, current_net_worth:, monthly_contribution:, annual_return:)
    @fi_number = fi_number
    @current_net_worth = current_net_worth
    @monthly_contribution = monthly_contribution
    @annual_return = annual_return
  end

  def call
    monthly_series = []
    balance = current_net_worth
    monthly_rate = annual_return / 12.0
    months = 0

    monthly_series << { month: months, balance: balance }
    while balance < fi_number && months < MAX_MONTHS
      balance = (balance * (1 + monthly_rate)) + monthly_contribution
      months += 1
      monthly_series << { month: months, balance: balance }
    end

    reached = balance >= fi_number
    {
      reached: reached,
      months: reached ? months : nil,
      target_date: reached ? Date.current.beginning_of_month >> months : nil,
      monthly_series: monthly_series
    }
  end

  def self.sensitivity_grid(fi_number:, current_net_worth:, monthly_contribution:,
                             return_rates: DEFAULT_RETURN_RATES, contribution_deltas: DEFAULT_CONTRIBUTION_DELTAS)
    return_rates.map do |return_rate|
      row = contribution_deltas.map do |delta|
        contribution = monthly_contribution * (1 + delta)
        result = new(
          fi_number: fi_number,
          current_net_worth: current_net_worth,
          monthly_contribution: contribution,
          annual_return: return_rate
        ).call
        {
          contribution_delta: delta,
          monthly_contribution: contribution,
          reached: result[:reached],
          months: result[:months],
          target_date: result[:target_date]
        }
      end
      { annual_return: return_rate, results: row }
    end
  end

  # Shared by the salary/spending solvers: how many months to reach FI given a
  # salary and spending level (fi_number and contribution capacity both derive
  # from those two numbers). Returns MAX_MONTHS + 1 (never MAX_MONTHS itself) when
  # not reached, so callers can compare against a target without a nil check.
  def self.months_to_reach(spending_annual_cents:, salary_annual_cents:, current_net_worth_cents:,
                            fixed_monthly_contribution_cents:, annual_return:, safe_withdrawal_rate:, tax_multiplier: 1.0)
    fi_number = spending_annual_cents / safe_withdrawal_rate
    cash_monthly_cents = (salary_annual_cents - spending_annual_cents) / 12.0
    total_monthly_cents = (cash_monthly_cents + fixed_monthly_contribution_cents) * tax_multiplier

    result = new(
      fi_number: fi_number / 100.0,
      current_net_worth: current_net_worth_cents / 100.0,
      monthly_contribution: total_monthly_cents / 100.0,
      annual_return: annual_return
    ).call

    result[:reached] ? result[:months] : MAX_MONTHS + 1
  end
end
