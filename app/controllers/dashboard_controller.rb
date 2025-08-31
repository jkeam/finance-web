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

    # charts
    @income_per_month = @all_transactions.where(category: :category_income).group_by_month(:transaction_date).sum(:amount_cents)
    @income_per_month.each do |k, v|
      @income_per_month[k] = (v * -1) / 100
    end

    # spend
    @spend = @transactions.group(:category).sum(:amount_cents)
    @spend.each do |k, v|
      @spend[k] = v / 100
    end

    # restaurants
    @restaurants = @all_transactions.where(category: :category_restaurants).group(:merchant).sum(:amount_cents)
    @restaurants.each do |k, v|
      @restaurants[k] = v / 100
    end

    # spend per month
    @spend_per_month = @transactions.group_by_month(:transaction_date).sum(:amount_cents)
    @spend_per_month.each do |k, v|
      @spend_per_month[k] = v / 100
    end

    @income_and_spending = [
      {name: 'Income', data: @income_per_month},
      {name: 'Spend', data: @spend_per_month}
    ]

    restaurants_per_month = @all_transactions.where(category: :category_restaurants)
      .group_by_month(:merchant)
      .sum(:amount_cents)
    restaurants_per_month.each do |k, v|
      restaurants_per_month[k] = v / 100
    end
    @spending_by_category_per_month = [
      {name: 'Restaurants', data: restaurants_per_month}
    ]
  end
end
