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

    # info at top
    @number_of_months = (@enddate.year * 12 + @enddate.month) - (@startdate.year * 12 + @startdate.month)
  end

  # GET /dashboard/spending
  def spending
    all_transactions = Transaction.between_dates(@startdate, @enddate)

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
      .group_by_month(:transaction_date, range: @startdate...@enddate, expand_range: true)
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
      sum = value.values.sum()
      value.nil? || value.keys().size.zero? || sum < 200
    end

    # spend per month
    @spend_per_month = spending_transactions
      .group_by_month(:transaction_date, range: @startdate...@enddate, expand_range: true)
      .sum(:amount_cents)
    @spend_per_month.each { |k, v| @spend_per_month[k] = v / 100 }
    @spending_by_category_per_month = Transaction.spending_per_category_per_month(@startdate, @enddate)
    @spending_by_category_per_month.reject! do |element|
      value = element[:data]
      sum = value.values.sum()
      sum.zero? || sum < 200
    end

    # income and spending
    @income_and_spending = [
      { name: "Income", data: @income_per_month },
      { name: "Spend", data: @spend_per_month }
    ]
    @net_per_month = @income_per_month.map { |k, v| [ k, v - @spend_per_month[k] ] }.to_h
    @income_spend_net = @income_per_month.map do |month, income|
      spend = @spend_per_month[month]
      {
        month:,
        income:,
        spend:,
        net: income - spend
      }
    end

    # balances
    @balances = []
    Account.where(id: all_balances.select(:account_id).distinct.pluck(:account_id)).each do |account|
      data = all_balances.where(account_id: account.id)
        .group_by_month(:date, range: @startdate...@enddate, expand_range: true)
        .sum(:amount_cents)
      @balances << {
        name: account.name,
        data: data.transform_values { |value| value / 100 }
      }
    end
  end

  # GET /dashboard/retirement
  def retirement
    @assumption = RetirementAssumption.current

    @spending_baseline = Transaction.spending_baseline(@startdate, @enddate)

    months = [ (@enddate.year * 12 + @enddate.month) - (@startdate.year * 12 + @startdate.month), 1 ].max
    income_cents_total = Transaction.income.between_dates(@startdate, @enddate).sum(:amount_cents) * -1
    @income_baseline_annual_cents = (income_cents_total.to_f / months * 12).round

    @savings_rate = @income_baseline_annual_cents.zero? ? 0 :
      (((@income_baseline_annual_cents - @spending_baseline[:annual_cents]).to_f / @income_baseline_annual_cents) * 100).round(1)

    investment_account_ids = Account.investment.pluck(:id)
    @current_net_worth_cents = investment_account_ids.sum do |account_id|
      Balance.where(account_id: account_id).order(date: :desc).limit(1).pick(:amount_cents) || 0
    end

    @fi_number_cents = @assumption.safe_withdrawal_rate.to_f.zero? ? 0 :
      (@spending_baseline[:annual_cents] / @assumption.safe_withdrawal_rate.to_f).round
    @monthly_contribution_cents = ((@income_baseline_annual_cents - @spending_baseline[:annual_cents]) / 12.0).round

    @projection = RetirementProjection.new(
      fi_number: @fi_number_cents / 100.0,
      current_net_worth: @current_net_worth_cents / 100.0,
      monthly_contribution: @monthly_contribution_cents / 100.0,
      annual_return: @assumption.expected_annual_return.to_f
    ).call
    @retirement_age = @assumption.age_on(@projection[:target_date]) if @projection[:reached]

    projected_net_worth = @projection[:monthly_series].map do |point|
      [ Date.current.beginning_of_month >> point[:month], point[:balance].round(2) ]
    end.to_h
    fi_number_dollars = @fi_number_cents / 100.0
    fi_number_line = projected_net_worth.keys.map { |date| [ date, fi_number_dollars ] }.to_h
    @net_worth_projection = [
      { name: "Projected Net Worth", data: projected_net_worth },
      { name: "FI Number", data: fi_number_line }
    ]

    @savings_rate_by_month = Transaction.income_and_spending_by_month(@startdate, @enddate)[:savings_rate_by_month]

    @sensitivity = RetirementProjection.sensitivity_grid(
      fi_number: fi_number_dollars,
      current_net_worth: @current_net_worth_cents / 100.0,
      monthly_contribution: @monthly_contribution_cents / 100.0
    )
    @sensitivity.each do |row|
      row[:results].each do |cell|
        cell[:age] = @assumption.age_on(cell[:target_date]) if cell[:reached]
      end
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
