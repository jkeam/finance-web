class Transaction < ApplicationRecord
  enum :category, {
    category_other: 0,
    category_payment: 1,
    category_installment: 2,
    category_interest: 3,
    category_credit: 4,
    category_debit: 5,
    category_deposit: 6,
    category_withdrawl: 7,
    category_income: 8,
    category_dividend: 9,
    category_shopping: 10,
    category_restaurants: 11,
    category_services: 12,
    category_grocery: 13,
    category_travel: 14,
    category_transportation: 15,
    category_health: 16,
    category_alcohol: 17,
    category_entertainment: 18,
    category_investment: 19,
    category_rent: 20,
    category_rental_property: 21,
    category_significant_other: 22,
    category_software: 23
  }
  enum :transaction_type, {
    type_purchase: 0,
    type_payment: 1,
    type_installment: 2,
    type_interest: 3,
    type_credit: 4,
    type_debit: 5
  }
  monetize :amount_cents
  belongs_to :bank
end
