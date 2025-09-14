class AccountsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @accounts = pagy(Account.includes(:bank).order(:id))
  end
end
