class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :budgets do |t|
      t.string :name, null: false, limit: 255
      t.timestamps
    end
    create_table :budget_transaction_categories do |t|
      t.monetize :amount, null: false
      t.references :budget, null: false, foreign_key: true
      t.integer :transaction_category, null: false
      t.timestamps
    end
    add_index :budget_transaction_categories, :transaction_category
    add_index :accounts, :category
    add_index :transactions, :category
    add_index :transactions, :transaction_type
  end
end
