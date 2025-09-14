class Bank < ApplicationRecord
  validates :name, uniqueness: true
  enum :category, {
    commercial: 0,
    credit_card: 1
  }
end
