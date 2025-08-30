class DashboardController < ApplicationController
  # GET /
  def index
    ignore_categories = %i[
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
    ]

    @sigother = (params[:sigother] || '').strip == 'true'

    @startdate = nil
    if params[:startdate].strip != ''
      @startdate = Date.strptime(params[:startdate], "%Y-%m-%d")
    end
    @endddate = nil
    if params[:enddate].strip != ''
      @enddate = Date.strptime(params[:enddate], "%Y-%m-%d")
    end

    unless @sigother
      ignore_categories << :category_significant_other
    end

    @transactions = Transaction.where.not(category: ignore_categories)
    @all_transactions = Transaction
    if @startdate != nil
      @transactions = @transactions.where('transaction_date >= ?', @startdate)
      @all_transactions = @all_transactions.where('transaction_date >= ?', @startdate)
    end
    if @enddate != nil
      @all_transactions = @all_transactions.where('transaction_date <= ?', @enddate)
    end
  end
end
