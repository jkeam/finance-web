class BalancesController < ApplicationController
  # GET /balances/new
  def new
    @balance = Balance.new(date: Date.current)
  end

  # POST /balances
  def create
    @balance = Balance.new(balance_params)

    if @balance.save
      redirect_to dashboard_retirement_path, notice: "Balance was successfully recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def balance_params
    params.expect(balance: [ :account_id, :date, :amount ])
  end
end
