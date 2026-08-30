class AddBirthdateToRetirementAssumptions < ActiveRecord::Migration[8.1]
  def change
    add_column :retirement_assumptions, :birthdate, :date
  end
end
