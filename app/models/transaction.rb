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
    category_software: 25,
    category_tax: 26,
    category_accounting: 27,
    category_insurance: 28
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
    query = query.where("transaction_date >= ?", startdate) if startdate != nil
    query = query.where("transaction_date <= ?", enddate) if enddate != nil
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
    category_tax
    category_accounting
    category_insurance
  ]
  def self.get_needs_categories
    @@needs_categories
  end

  def self.pretty_print_category(category)
    (category || "").to_s.gsub("category_", "").titleize
  end

  def self.pretty_print_type(type)
    (type || "").gsub("type_", "").titleize
  end

  def self.spending_category_by_month(transactions, startdate, enddate, category)
    tmp = transactions.where(category: category)
      .group_by_month(:transaction_date, range: startdate...enddate, expand_range: true)
      .sum(:amount_cents)
    tmp.each do |k, v|
      tmp[k] = v / 100
      tmp[k] ||= 0
    end
    tmp
  end

  def self.spending_baseline(startdate, enddate)
    spending_transactions = spending().between_dates(startdate, enddate)
    months = ((enddate.year * 12 + enddate.month) - (startdate.year * 12 + startdate.month))
    months = 1 if months < 1

    total_cents = spending_transactions.sum(:amount_cents)
    needs_cents = spending_transactions.where(category: get_needs_categories()).sum(:amount_cents)
    wants_cents = total_cents - needs_cents

    {
      annual_cents: (total_cents.to_f / months * 12).round,
      needs_annual_cents: (needs_cents.to_f / months * 12).round,
      wants_annual_cents: (wants_cents.to_f / months * 12).round,
      monthly_avg_cents: (total_cents.to_f / months).round
    }
  end

  # Annualized income and spending per calendar year across all history, ignoring any
  # date filter. Years with fewer than 12 complete months of data (first/last year) are scaled up
  # from the months they do have, and flagged as partial.
  def self.annual_history
    # Future-dated transactions are never counted.
    past = where("transaction_date <= ?", Date.current)
    first = past.minimum(:transaction_date)
    last = past.maximum(:transaction_date)
    return [] if first.nil?

    # Only whole months: a first month that starts mid-month, or a last/current month that
    # hasn't finished, would otherwise read as a tiny "full" month and wildly skew the
    # annualized figures.
    start_month = first.day == 1 ? first.beginning_of_month : first.next_month.beginning_of_month
    last_complete = Date.current.beginning_of_month - 1.day
    last = last.prev_month.end_of_month unless last == last.end_of_month
    end_month = [ last, last_complete ].min.end_of_month
    return [] if start_month > end_month

    range = start_month..end_month
    income = income().group_by_month(:transaction_date, range: range).sum(:amount_cents)
    spend = spending().group_by_month(:transaction_date, range: range).sum(:amount_cents)

    income.keys.group_by(&:year).sort.map do |year, months|
      count = months.size
      income_cents = (months.sum { |m| income[m] } * -1.0 / count * 12).round
      spending_cents = (months.sum { |m| spend[m] || 0 }.to_f / count * 12).round
      {
        year: year,
        months: count,
        partial: count < 12,
        income_cents: income_cents,
        spending_cents: spending_cents,
        savings_rate: income_cents.zero? ? 0 : ((income_cents - spending_cents).to_f / income_cents * 100).round(1)
      }
    end
  end

  # Month-weighted average of annual_history rows, so a one-month year counts for one
  # month's worth of data rather than as much as a full year.
  def self.annual_history_average(history)
    total_months = history.sum { |y| y[:months] }
    return nil if total_months.zero?

    income_cents = (history.sum { |y| y[:income_cents] * y[:months] }.to_f / total_months).round
    spending_cents = (history.sum { |y| y[:spending_cents] * y[:months] }.to_f / total_months).round
    {
      months: total_months,
      income_cents: income_cents,
      spending_cents: spending_cents,
      savings_rate: income_cents.zero? ? 0 : ((income_cents - spending_cents).to_f / income_cents * 100).round(1)
    }
  end

  def self.income_and_spending_by_month(startdate, enddate)
    income_transactions = income().between_dates(startdate, enddate)
    spending_transactions = spending().between_dates(startdate, enddate)

    income_per_month = income_transactions
      .group_by_month(:transaction_date, range: startdate...enddate, expand_range: true)
      .sum(:amount_cents)
    income_per_month.each { |k, v| income_per_month[k] = (v * -1) / 100 }

    spend_per_month = spending_transactions
      .group_by_month(:transaction_date, range: startdate...enddate, expand_range: true)
      .sum(:amount_cents)
    spend_per_month.each { |k, v| spend_per_month[k] = v / 100 }

    savings_rate_by_month = income_per_month.map do |month, income|
      spend = spend_per_month[month] || 0
      rate = income.zero? ? 0 : ((income - spend).to_f / income * 100).round(1)
      [ month, rate ]
    end.to_h

    {
      income_per_month: income_per_month,
      spend_per_month: spend_per_month,
      savings_rate_by_month: savings_rate_by_month
    }
  end

  def self.spending_per_category_per_month(startdate, enddate)
    all_transactions = between_dates(startdate, enddate)
    categories = %i[
      category_restaurants
      category_services
      category_grocery
      category_utility
      category_shopping
      category_travel
      category_transportation
      category_health
      category_alcohol
      category_entertainment
      category_software
      category_significant_other
      category_other
      category_rent
      category_rental_property
      category_tax
      category_accounting
      category_insurance
    ]

    spending_by_category_per_month = categories.map do |category|
      data = spending_category_by_month(all_transactions, startdate, enddate, category)
      sorted = data.values.compact.sort
      # median start
      len = sorted.length
      if sorted
        if len.odd?
          median = sorted[len / 2]
        elsif len > 0
          median = (sorted[len / 2] + sorted[(len / 2) - 1]) / 2
        end
      end
      # median end
      {
        name: pretty_print_category(category),
        category: category,
        data: data,
        min: sorted[0] || 0,
        max: sorted[-1] || 0,
        mean: (data.values.inject(&:+) / data.values.size) || 0,
        median: median || 0
      }
    end
    spending_by_category_per_month
  end
end
