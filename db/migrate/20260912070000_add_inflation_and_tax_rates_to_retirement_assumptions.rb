class AddInflationAndTaxRatesToRetirementAssumptions < ActiveRecord::Migration[8.1]
  def change
    add_column :retirement_assumptions, :inflation_rate, :decimal, precision: 5, scale: 4, null: false, default: 0.03
    add_column :retirement_assumptions, :pretax_effective_tax_rate, :decimal, precision: 5, scale: 4, null: false, default: 0.0
    add_column :retirement_assumptions, :capital_gains_tax_rate, :decimal, precision: 5, scale: 4, null: false, default: 0.0
  end
end
