class TransactionsController < ApplicationController
  include Pagy::Backend
  def index
    ignore_categories = %i[]
    @sigother = (params[:sigother] || '').strip == 'true'

    @startdate = nil
    if ((params[:startdate] || '').strip != '')
      @startdate = Date.strptime(params[:startdate], "%Y-%m-%d")
    end
    @endddate = nil
    if ((params[:enddate] || '').strip != '')
      @enddate = Date.strptime(params[:enddate], "%Y-%m-%d")
    end

    unless @sigother
      ignore_categories << :category_significant_other
    end

    transactions = Transaction.where.not(category: ignore_categories)
    if @startdate != nil
      transactions = transactions.where('transaction_date >= ?', @startdate)
    end
    if @enddate != nil
      transactions = transactions.where('transaction_date <= ?', @enddate)
    end
    @pagy, @transactions = pagy(transactions)
  end
end
