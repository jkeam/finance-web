class DashboardController < ApplicationController
  include Filterable

  # GET /
  def index
    set_filter_params(params)
    @ignore_categories.concat(%i[
      category_payment
      category_credit
      category_debit
      category_installment
      category_interest
      category_other
      category_income
      category_transfer
      category_deposit
      category_withdrawl
      category_dividend
      category_rental_property
      category_software
    ])
    @transactions = Transaction.where.not(category: @ignore_categories)
    @all_transactions = Transaction
    if @startdate != nil
      @transactions = @transactions.where('transaction_date >= ?', @startdate)
      @all_transactions = @all_transactions.where('transaction_date >= ?', @startdate)
    end
    if @enddate != nil
      @transactions = @transactions.where('transaction_date <= ?', @enddate)
      @all_transactions = @all_transactions.where('transaction_date <= ?', @enddate)
    end

    @income_per_month = @all_transactions.where(category: :category_income)
      .group_by_month(:transaction_date)
      .sum(:amount_cents)
    @income_per_month.each do |k, v|
      @income_per_month[k] = (v * -1) / 100
    end

    @income_per_month_by_merchant = @all_transactions.where(category: :category_income).select(:merchant).distinct.pluck(:merchant).map do |m|
      {
        name: m,
        data: income_by_merchant_and_month(@all_transactions, m)
      }
    end
    @spending_by_category_per_month = [
      { name: 'Restaurants', data: spending_category_by_month(@all_transactions, :category_restaurants) },
      { name: 'Services', data: spending_category_by_month(@all_transactions, :category_services) },
    ]

    # spend per category
    @spend = @transactions.group(:category).sum(:amount_cents)
    @spend.each do |k, v|
      @spend[k] = v / 100
    end

    # restaurants per merchant
    @restaurants = @all_transactions.where(category: :category_restaurants)
      .group(:merchant)
      .having('sum(amount_cents) > 10000')
      .sum(:amount_cents)
    @restaurants.each do |k, v|
      @restaurants[k] = v / 100
    end

    # restaurant times
    @restaurant_times = @all_transactions.where(category: :category_restaurants)
      .group(:merchant)
      .having('count(merchant) > 5')
      .count

    # grocery per merchant
    @grocery = @all_transactions.where(category: :category_grocery)
      .group(:merchant)
      .having('sum(amount_cents) > 10000')
      .sum(:amount_cents)
    @grocery.each do |k, v|
      @grocery[k] = v / 100
    end

    @all_services = @all_transactions.where(category: :category_services)
      .group(:merchant)
      .sum(:amount_cents)
    @all_services.each do |k, v|
      @all_services[k] = v / 100
    end
    @services = @all_transactions.where(category: :category_services)
      .group(:merchant)
      .having('sum(amount_cents) > 10000')
      .sum(:amount_cents)
    @services.each do |k, v|
      @services[k] = v / 100
    end

    @spend_per_month = @transactions.group_by_month(:transaction_date).sum(:amount_cents)
    @spend_per_month.each do |k, v|
      @spend_per_month[k] = v / 100
    end

    @income_and_spending = [
      { name: 'Income', data: @income_per_month },
      { name: 'Spend', data: @spend_per_month }
    ]

    @net_per_month = @income_per_month.map { |k, v| [ k, v - @spend_per_month[k] ] }.to_h

    # info
    @net_amount = @net_per_month.values().inject(0) { |acc, n| acc + n }
    @net_spending_amount = @spend_per_month.values().inject(0) { |acc, n| acc + n }
    @net_income_amount = @income_per_month.values().inject(0) { |acc, n| acc + n }
    @number_of_months = @income_per_month.keys().size

    @spending_by_category_per_month = [
      { name: 'Restaurants', data: spending_category_by_month(@all_transactions, :category_restaurants) },
      { name: 'Services', data: spending_category_by_month(@all_transactions, :category_services) },
      { name: 'Grocery', data: spending_category_by_month(@all_transactions, :category_grocery) },
      { name: 'Utilities', data: spending_category_by_month(@all_transactions, :category_utility) },
      { name: 'Shopping', data: spending_category_by_month(@all_transactions, :category_shopping) },
      { name: 'Travel', data: spending_category_by_month(@all_transactions, :category_travel) },
      { name: 'Transportation', data: spending_category_by_month(@all_transactions, :category_transportation) }
    ]
  end
end
