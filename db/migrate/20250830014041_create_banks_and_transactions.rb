class CreateBanksAndTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :banks do |t|
      t.string :name, null: false
      t.timestamps
    end
    create_table :accounts do |t|
      t.string :name, null: false
      t.integer :category, null: false
      t.references :bank, null: false, foreign_key: true
      t.timestamps
    end
    create_table :transactions do |t|
      t.date :transaction_date, null: false
      t.date :clearing_date, null: true
      t.string :description, null: true, limit: 255
      t.string :merchant, null: true, limit: 255
      t.integer :category, default: 0
      t.integer :transaction_type, default: 0
      t.string :purchased_by, null: true, limit: 255
      t.text :notes, null: true
      t.monetize :amount, null: false
      t.boolean :positive, default: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
    add_index :banks, :name, unique: true
  end
end
