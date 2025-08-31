class BanksController < ApplicationController
  include Pagy::Backend
  def index
    @pagy, @banks = pagy(Bank.all.order(:id))
  end
end
