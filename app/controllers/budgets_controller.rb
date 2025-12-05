class BudgetsController < ApplicationController
  include Pagy::Method
  before_action :set_budget, only: %i[ show edit update destroy ]

  # GET /budgets
  def index
    @pagy, @budgets = pagy(Budget.all.order(:id))
  end

  # GET /budgets/1
  def show
    @budget = Budget.where(id: params.expect(:id)).includes(:budget_transaction_categories).first
    @budget_transaction_categories = BudgetTransactionCategory.all.group(:transaction_category).sum(:amount_cents)
    @budget_transaction_categories.transform_keys! { |key| Transaction.pretty_print_category(Transaction.categories.key(key)) }

    last_month = (Date.current << 1)
    @spending_by_category_per_month = Transaction.spending_per_category_per_month(last_month << 5, last_month)
  end

  # GET /budgets/new
  def new
    @budget = Budget.new
  end

  # GET /budgets/1/edit
  def edit; end

  # POST /budgets or /budgets.json
  def create
    @budget = Budget.new(budget_params)

    respond_to do |format|
      if @budget.save
        format.html { redirect_to @budget, notice: "Budget was successfully created." }
        # format.json { render :show, status: :created, location: @budget }
      else
        format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /budgets/1 or /budgets/1.json
  def update
    respond_to do |format|
      if @budget.update(budget_params)
        format.html { redirect_to @budget, notice: "Budget was successfully updated.", status: :see_other }
        # format.json { render :show, status: :ok, location: @budget }
      else
        format.html { render :edit, status: :unprocessable_entity }
        # format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /budgets/1 or /budgets/1.json
  def destroy
    @budget.destroy!

    respond_to do |format|
      format.html { redirect_to budgets_path, notice: "Budget was successfully destroyed.", status: :see_other }
      # format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_budget
      @budget = Budget.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def budget_params
      params.expect(budget: [ :name, budget_transaction_categories_attributes: [[ :id, :amount, :transaction_category, :_destroy ]]])
    end
end
