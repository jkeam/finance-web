class Budget < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  has_many :budget_transaction_categories, -> { order(amount_cents: :desc) }, inverse_of: :budget, dependent: :destroy
  accepts_nested_attributes_for :budget_transaction_categories, reject_if: :all_blank, allow_destroy: true
end
