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
end
