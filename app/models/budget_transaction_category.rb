class BudgetTransactionCategory < ApplicationRecord
  monetize :amount_cents, allow_nil: false
  belongs_to :budget, inverse_of: :budget_transaction_categories
  validates :transaction_category, presence: true
end
