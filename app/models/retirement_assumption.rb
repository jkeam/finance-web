class RetirementAssumption < ApplicationRecord
  validates :safe_withdrawal_rate, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :expected_annual_return, presence: true, numericality: { greater_than: -1 }

  def self.current
    first_or_initialize
  end

  def age_on(date)
    return nil if birthdate.nil?

    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
  end
end
