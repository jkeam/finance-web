class Transaction < ApplicationRecord
  enum :category, {
    category_other: 0,
    category_payment: 1,
    category_installment: 2,
    category_interest: 3,
    category_deposit: 4,
    category_withdrawl: 5,
    category_income: 6,
    category_dividend: 7,
    category_shopping: 8,
    category_restaurants: 9,
    category_services: 10,
    category_grocery: 11,
    category_travel: 12,
    category_health: 13,
    category_investment: 14,
    category_rent: 15,
    category_rental_property: 16,
    category_significant_other: 17
  }
  enum :transaction_type, {
    type_purchase: 0,
    type_payment: 1,
    type_installment: 2,
    type_interest: 3,
    type_credit: 4
  }
  monetize :amount_cents
  belongs_to :bank
end
