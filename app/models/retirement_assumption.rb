class RetirementAssumption < ApplicationRecord
  validates :safe_withdrawal_rate, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :expected_annual_return, presence: true, numericality: { greater_than: -1 }
  validates :inflation_rate, presence: true, numericality: { greater_than: -1 }
  validates :pretax_effective_tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 1 }
  validates :capital_gains_tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 1 }

  def self.current
    first_or_initialize
  end

  def age_on(date)
    return nil if birthdate.nil?

    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
  end

  # expected_annual_return is treated as a nominal return; this nets out
  # inflation (Fisher equation) so projections can run entirely in today's dollars.
  def real_annual_return
    ((1 + expected_annual_return.to_f) / (1 + inflation_rate.to_f)) - 1
  end

  def target_retirement_date
    return nil if birthdate.nil? || target_retirement_age.nil?

    birthdate + target_retirement_age.years
  end
end
