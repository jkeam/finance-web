class RetirementAssumptionsController < ApplicationController
  before_action :set_retirement_assumption

  # GET /retirement_assumption/edit
  def edit; end

  # PATCH/PUT /retirement_assumption
  def update
    if @retirement_assumption.update(retirement_assumption_params)
      redirect_to dashboard_retirement_path, notice: "Retirement assumptions were successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_retirement_assumption
    @retirement_assumption = RetirementAssumption.current
  end

  def retirement_assumption_params
    params.expect(retirement_assumption: [ :safe_withdrawal_rate, :expected_annual_return, :target_retirement_age, :birthdate ])
  end
end
