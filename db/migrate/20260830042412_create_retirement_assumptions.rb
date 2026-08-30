class CreateRetirementAssumptions < ActiveRecord::Migration[8.1]
  def change
    create_table :retirement_assumptions do |t|
      t.decimal :safe_withdrawal_rate, precision: 5, scale: 4, null: false, default: 0.04
      t.decimal :expected_annual_return, precision: 5, scale: 4, null: false, default: 0.07
      t.integer :target_retirement_age

      t.timestamps
    end
  end
end
