class DashboardController < ApplicationController
  include Filterable
  before_action :set_filter_params

  # GET /dashboard
  def index; end

  # GET /dashboard/yearly
  def yearly
    all_transactions = Transaction.between_dates(@startdate, @enddate)
    income_transactions = Transaction.income().between_dates(@startdate, @enddate)
    spending_transactions = Transaction.spending().between_dates(@startdate, @enddate)

    # spend per category
    @spend = spending_transactions.group(:category).sum(:amount_cents)
    @spend.each { |k, v| @spend[k] = v / 100 }
    @spend.transform_keys! { |key| Transaction.pretty_print_category(key) }
    # needs spend per category
    @needs = spending_transactions.where(category: Transaction.get_needs_categories())
      .group(:category).sum(:amount_cents)
    @needs.each { |k, v| @needs[k] = v / 100 }
    @needs.transform_keys! { |key| Transaction.pretty_print_category(key) }
    # wants spend per category
    @wants = spending_transactions.where.not(category: Transaction.get_needs_categories())
      .group(:category).sum(:amount_cents)
    @wants.each { |k, v| @wants[k] = v / 100 }
    @wants.transform_keys! { |key| Transaction.pretty_print_category(key) }

    # spend count
    @spend_count = spending_transactions.group(:category).count
    @spend_count.transform_keys! { |key| Transaction.pretty_print_category(key) }

    # budget
    @summary_income = (income_transactions.sum(:amount_cents) * -1) || 0
    @summary_spending = (spending_transactions.sum(:amount_cents)) || 0
    budget_spending_needs = all_transactions.where(category: Transaction.get_needs_categories()).sum(:amount_cents) || 0
    budget_spending_wants = @summary_spending - budget_spending_needs || 0
    @budget_savings = @summary_income - @summary_spending
    @budget_spending = {
      "Needs" => budget_spending_needs / 100,
      "Wants" => budget_spending_wants / 100,
      "Savings" => @budget_savings / 100
    }

    # info
    @number_of_months = @enddate.month - @startdate.month
    @number_of_months = 1 if @number_of_months.zero?
  end

  # GET /dashboard/spending
  def spending
    all_transactions = Transaction.all.between_dates(@startdate, @enddate)

    # restaurants
    @restaurants = all_transactions.where(category: :category_restaurants)
      .group(:merchant)
      .having("sum(amount_cents) > 10000")
      .sum(:amount_cents)
    @restaurants.each { |k, v| @restaurants[k] = v / 100 }
    # restaurant occurances
    @restaurant_times = all_transactions.where(category: :category_restaurants)
      .group(:merchant)
      .having("count(merchant) > 5")
      .count

    # grocery per merchant
    @grocery = all_transactions.where(category: :category_grocery)
      .group(:merchant)
      .having("sum(amount_cents) > 10000")
      .sum(:amount_cents)
    @grocery.each { |k, v| @grocery[k] = v / 100 }

    # services
    @services = all_transactions.where(category: :category_services)
      .group(:merchant)
      .sum(:amount_cents)
    @services.each { |k, v| @services[k] = v / 100 }
    # services grouped by merchants
    @services_expensive = all_transactions.where(category: :category_services)
      .group(:merchant)
      .having("sum(amount_cents) > 10000")
      .sum(:amount_cents)
    @services_expensive.each { |k, v| @services_expensive[k] = v / 100 }
  end

  # GET /dashboard/monthly
  def monthly
    all_transactions = Transaction.between_dates(@startdate, @enddate)
    income_transactions = Transaction.income().between_dates(@startdate, @enddate)
    spending_transactions = Transaction.spending().between_dates(@startdate, @enddate)
    all_balances = Balance.between_dates(@startdate, @enddate)

    # income
    @income_per_month = income_transactions
      .group_by_month(:transaction_date, range: @startdate..@enddate, expand_range: true)
      .sum(:amount_cents)
    @income_per_month.each { |k, v| @income_per_month[k] = (v * -1) / 100 }
    @income_per_month_by_merchant = income_transactions.select(:merchant).distinct.pluck(:merchant).map do |m|
      {
        name: m[0...30],
        data: income_by_merchant_and_month(income_transactions, @startdate, @enddate, m)
      }
    end
    @income_per_month_by_merchant.reject! do |merchant|
      value = merchant[:data]
      value.nil? || value.keys().size.zero?
    end

    # spend per month
    @spend_per_month = spending_transactions
      .group_by_month(:transaction_date, range: @startdate..@enddate, expand_range: true)
      .sum(:amount_cents)
    @spend_per_month.each { |k, v| @spend_per_month[k] = v / 100 }
    @spending_by_category_per_month = [
      { name: "Restaurants", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_restaurants) },
      { name: "Services", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_services) },
      { name: "Grocery", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_grocery) },
      { name: "Utilities", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_utility) },
      { name: "Shopping", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_shopping) },
      { name: "Travel", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_travel) },
      { name: "Transportation", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_transportation) },
      { name: "Health", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_health) },
      { name: "Alcohol", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_alcohol) },
      { name: "Entertainment", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_entertainment) },
      { name: "Software", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_software) },
      { name: "Significant Other", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_significant_other) },
      { name: "Other", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_other) },
      { name: "Rent", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_rent) },
      { name: "Rental Property", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_rental_property) }
    ]
    @spending_by_category_per_month.each do |s|
      data = s[:data]
      s[:mean] = data.values.inject(&:+) / data.values.size
    end

    # income and spending
    @income_and_spending = [
      { name: "Income", data: @income_per_month },
      { name: "Spend", data: @spend_per_month }
    ]
    @net_per_month = @income_per_month.map { |k, v| [ k, v - @spend_per_month[k] ] }.to_h

    # balances
    @balances = []
    Account.where(id: all_balances.select(:account_id).distinct.pluck(:account_id)).each do |account|
      @balances << {
        name: account.name,
        data: all_balances.where(account_id: account.id)
        .group_by_month(:date, range: @startdate..@enddate, expand_range: true)
        .sum(:amount_cents)
      }
    end
  end

  # GET /dashboard/trends
  def trends
    create_spending = lambda do |thestart, theend|
      spend = Transaction.spending()
        .where("transaction_date >= ?", thestart)
        .where("transaction_date <= ?", theend)
        .group(:category).sum(:amount_cents)
      spend.each { |k, v| spend[k] = v / 100 }
      spend.transform_keys! { |key| Transaction.pretty_print_category(key) }
      spend
    end

    @spending = []
    cur_date = @startdate
    while cur_date < @enddate
      @spending << {
        name: cur_date,
        data: create_spending.call(cur_date, cur_date.next_month)
      }
      cur_date = cur_date.next_month
    end
  end
end
