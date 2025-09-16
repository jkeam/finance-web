class DashboardController < ApplicationController
  include Filterable

  # GET /dashboard
  def index
    set_filter_params(params)

    all_transactions = Transaction.all
    needs_transactions = Transaction.all.where(category: Transaction.get_needs_categories())

    # used for spending to ignore income and internal transfers and payments
    income_transactions = Transaction.income()
    spending_transactions = Transaction.spending()

    all_balances = Balance.all

    # params
    if @startdate != nil
      all_transactions = all_transactions.where("transaction_date >= ?", @startdate)
      needs_transactions = needs_transactions.where("transaction_date >= ?", @startdate)
      income_transactions = income_transactions.where("transaction_date >= ?", @startdate)
      spending_transactions = spending_transactions.where("transaction_date >= ?", @startdate)
      all_balances.where("date >= ?", @startdate)
    end
    if @enddate != nil
      all_transactions = all_transactions.where("transaction_date <= ?", @enddate)
      needs_transactions = needs_transactions.where("transaction_date <= ?", @enddate)
      income_transactions = income_transactions.where("transaction_date <= ?", @enddate)
      spending_transactions = spending_transactions.where("transaction_date <= ?", @enddate)
      all_balances.where("date <= ?", @enddate)
    end

    # income
    @income_per_month = income_transactions
      .group_by_month(:transaction_date, range: @startdate..@enddate, expand_range: true)
      .sum(:amount_cents)
    @income_per_month.each do |k, v|
      @income_per_month[k] = (v * -1) / 100
    end
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

    # spending
    @spending_by_category_per_month = [
      { name: "Restaurants", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_restaurants) },
      { name: "Services", data: spending_category_by_month(all_transactions, @startdate, @enddate, :category_services) }
    ]
    # spend per category
    @spend = spending_transactions.group(:category).sum(:amount_cents)
    @spend.each { |k, v| @spend[k] = v / 100 }
    @spend.transform_keys! do |key|
      key.gsub("category_", "")
    end
    # needs spend per category
    @needs = spending_transactions.where(category: Transaction.get_needs_categories())
      .group(:category).sum(:amount_cents)
    @needs.each { |k, v| @needs[k] = v / 100 }
    @needs.transform_keys! do |key|
      key.gsub("category_", "")
    end
    # wants spend per category
    @wants = spending_transactions.where.not(category: Transaction.get_needs_categories())
      .group(:category).sum(:amount_cents)
    @wants.each { |k, v| @wants[k] = v / 100 }
    @wants.transform_keys! do |key|
      key.gsub("category_", "")
    end
    # spend per month
    @spend_per_month = spending_transactions
      .group_by_month(:transaction_date, range: @startdate..@enddate, expand_range: true)
      .sum(:amount_cents)
    @spend_per_month.each do |k, v|
      @spend_per_month[k] = v / 100
    end
    @spend_count = spending_transactions.group(:category).count
    @spend_count.transform_keys! do |key|
      key.gsub("category_", "")
    end
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

    # income and spending
    @income_and_spending = [
      { name: "Income", data: @income_per_month },
      { name: "Spend", data: @spend_per_month }
    ]
    @net_per_month = @income_per_month.map { |k, v| [ k, v - @spend_per_month[k] ] }.to_h

    # budget
    @summary_income = (income_transactions.sum(:amount_cents) * -1) || 0
    @summary_spending = (spending_transactions.sum(:amount_cents)) || 0
    budget_spending_needs = all_transactions.where(category: Transaction.get_needs_categories()).sum(:amount_cents) || 0
    budget_spending_wants = @summary_spending - budget_spending_needs || 0
    @budget_savings = @summary_income - @summary_spending
    @budget_spending = {
      "needs" => budget_spending_needs / 100,
      "wants" => budget_spending_wants / 100,
      "savings" => @budget_savings / 100
    }

    # info
    @number_of_months = @income_per_month.keys().size
    if @number_of_months.zero?
      @number_of_months = 1
    end

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

  # GET /dashboard/spending
  def spending
    set_filter_params(params)

    all_transactions = Transaction.all

    # params
    if @startdate != nil
      all_transactions = all_transactions.where("transaction_date >= ?", @startdate)
    end
    if @enddate != nil
      all_transactions = all_transactions.where("transaction_date <= ?", @enddate)
    end

    # restaurants
    @restaurants = all_transactions.where(category: :category_restaurants)
      .group(:merchant)
      .having("sum(amount_cents) > 10000")
      .sum(:amount_cents)
    @restaurants.each do |k, v|
      @restaurants[k] = v / 100
    end
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
    @grocery.each do |k, v|
      @grocery[k] = v / 100
    end

    # services
    @services = all_transactions.where(category: :category_services)
      .group(:merchant)
      .sum(:amount_cents)
    @services.each do |k, v|
      @services[k] = v / 100
    end
    # services grouped by merchants
    @services_expensive = all_transactions.where(category: :category_services)
      .group(:merchant)
      .having("sum(amount_cents) > 10000")
      .sum(:amount_cents)
    @services_expensive.each do |k, v|
      @services_expensive[k] = v / 100
    end
  end
end
