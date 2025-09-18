class Transaction < ApplicationRecord
  monetize :amount_cents, allow_nil: false
  belongs_to :account, inverse_of: :transactions

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

  # CC:
    # - (ignore, should match bank tranfer) Payment: is a transfer from a bank
    # - (income) Credit: Refund
    # - (spend) Installment: Big Purchase
    # - (spend) Debit: Deduction
    # - (spend) Interest: Late payment
    # - (spend) Purchase: Buying stuff
  # Bank:
    # - (income) Credit: Being paid
    # - (spend) Debit: ATM cash withdrawl
    # - (ignore, covered by CC transactions) Transfer: Paying CC
    #   - except rental_property since that's not synced here
    # - (spend) Purchase: Buying stuff
    # - (spend) Payment: Bills
  scope :spending, -> {
    joins(:account)
      .where(account: { category: Account.commercial_categories() },
             transaction_type: %i[type_debit type_purchase type_payment])
      .or(where(account: { category: :credit_card },
                transaction_type: %i[type_installment type_debit type_interest type_purchase]))
      .or(where(account: { category: Account.commercial_categories() },
                category: :category_rental_property))
  }
  scope :income, -> { where(transaction_type: :type_credit) }
  scope :between_dates, ->(startdate, enddate) {
    query = self
    query = where("transaction_date >= ?", startdate) if startdate != nil
    query = where("transaction_date <= ?", enddate) if enddate != nil
    query
  }

  @@needs_categories = %i[
    category_grocery
    category_utility
    category_health
    category_transportation
    category_rent
    category_rental_property
    category_interest
  ]
  def self.get_needs_categories
    @@needs_categories
  end
  def self.pretty_print_category(category)
    (category || '').gsub('category_', '').titleize
  end
  def self.pretty_print_type(type)
    (type || '').gsub('type_', '').titleize
  end
end
