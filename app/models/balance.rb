class Balance < ApplicationRecord
  monetize :amount_cents, allow_nil: false
  belongs_to :account, inverse_of: :balances

  scope :between_dates, ->(startdate, enddate) {
    query = self
    query = where("date >= ?", startdate) if startdate != nil
    query = where("date <= ?", enddate) if enddate != nil
    query
  }

  def to_s
    "amount: #{self.amount}, date: #{self.date}, account_id: #{self.account_id}"
  end
end
