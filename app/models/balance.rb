class Balance < ApplicationRecord
  monetize :amount_cents
  belongs_to :account

  def to_s
    "amount: #{self.amount}, date: #{self.date}, account_id: #{self.account_id}"
  end
end
