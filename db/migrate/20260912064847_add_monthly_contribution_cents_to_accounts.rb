class AddMonthlyContributionCentsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :monthly_contribution_cents, :integer, null: false, default: 0
    add_column :accounts, :monthly_contribution_currency, :string, null: false, default: "USD"
  end
end
