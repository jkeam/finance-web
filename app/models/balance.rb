class Balance < ApplicationRecord
  monetize :amount_cents
  belongs_to :account
end
