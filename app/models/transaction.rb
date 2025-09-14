class Transaction < ApplicationRecord
  enum :category, {
    category_other: 0,
    category_payment: 1,
    category_installment: 2,
    category_interest: 3,
    category_credit: 4,
    category_debit: 5,
    category_transfer: 6,
    category_deposit: 7,
    category_withdrawl: 8,
    category_income: 9,
    category_dividend: 10,
    category_shopping: 11,
    category_restaurants: 12,
    category_services: 13,
    category_grocery: 14,
    category_utility: 15,
    category_travel: 16,
    category_transportation: 17,
    category_health: 18,
    category_alcohol: 19,
    category_entertainment: 20,
    category_investment: 21,
    category_rent: 22,
    category_rental_property: 23,
    category_significant_other: 24,
    category_software: 25
  }
  enum :transaction_type, {
    type_purchase: 0,
    type_payment: 1,
    type_installment: 2,
    type_interest: 3,
    type_credit: 4,
    type_debit: 5,
    type_transfer: 6
  }

  @@needs_categories = %i[
    category_grocery
    category_utility
    category_health
    category_transportation
    category_rent
    category_rental_property
  ]
  def self.get_needs_categories
    @@needs_categories
  end

  @@wants_categories = %i[
    category_shopping
    category_restaurants
    category_services
    category_travel
    category_alcohol
    category_entertainment
    category_investment
    category_significant_other
    category_software
  ]
  def self.get_wants_categories
    @@wants_categories
  end

  @@income_categories = %i[
    category_dividend
    category_interest
    category_credit
    category_deposit
    category_income
  ]
  def self.get_income_categories
    @@income_categories
  end

  @@income_types = %i[
    type_credit
    type_dividend
  ]
  def self.get_income_types
    @@income_types
  end

  @@spend_types = %i[
    type_payment
    type_purchase
    type_transfer
    type_debit
  ]
  def self.get_spend_types
    @@spend_types
  end

  monetize :amount_cents
  belongs_to :bank
end
