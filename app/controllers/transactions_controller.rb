class TransactionsController < ApplicationController
  include Pagy::Backend
  include Filterable

  def index
    set_filter_params(params)
    transactions = Transaction.includes(:bank).where.not(category: @ignore_categories)
    if @startdate != nil
      transactions = transactions.where('transaction_date >= ?', @startdate)
    end
    if @enddate != nil
      transactions = transactions.where('transaction_date <= ?', @enddate)
    end
    @pagy, @transactions = pagy(transactions.order(:transaction_date))
  end
end
