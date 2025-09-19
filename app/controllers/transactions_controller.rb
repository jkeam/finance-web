class TransactionsController < ApplicationController
  include Pagy::Backend
  include Filterable
  before_action :set_transaction, only: %i[show]
  before_action :set_filter_params, only: :index

  # GET /transactions
  def index
    transactions = Transaction.includes(:account)
    if @startdate != nil
      transactions = transactions.where("transaction_date >= ?", @startdate)
    end
    if @enddate != nil
      transactions = transactions.where("transaction_date <= ?", @enddate)
    end
    @pagy, @transactions = pagy(transactions.order(:transaction_date))
  end

  # GET /transactions/
  def show; end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end
end
