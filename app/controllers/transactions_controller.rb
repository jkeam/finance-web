class TransactionsController < ApplicationController
  include Pagy::Backend
  def index
    @pagy, @transactions = pagy(Transaction.all)
  end
end
