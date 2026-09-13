class AddTaxTreatmentToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :tax_treatment, :integer
    add_index :accounts, :tax_treatment
  end
end
