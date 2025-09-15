class AccountsController < ApplicationController
  include Pagy::Backend
  before_action :set_account, only: %i[show]

  # GET /accounts
  def index
    @pagy, @accounts = pagy(Account.includes(:bank).order(:id))
  end

  # GET /accounts/1
  def show
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
