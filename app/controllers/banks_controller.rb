class BanksController < ApplicationController
  include Pagy::Backend
  before_action :set_bank, only: %i[show]

  # GET /banks
  def index
    @pagy, @banks = pagy(Bank.all.order(:id))
  end

  # GET /banks/1
  def show; end

  private
    def set_bank
      @bank = Bank.where(id: params[:id]).includes(:accounts).first
    end
end
