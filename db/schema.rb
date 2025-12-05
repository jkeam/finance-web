# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_09_17_222655) do
  create_table "accounts", force: :cascade do |t|
    t.integer "bank_id", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_accounts_on_bank_id"
    t.index ["category"], name: "index_accounts_on_category"
  end

  create_table "balances", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_balances_on_account_id"
  end

  create_table "banks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_banks_on_name", unique: true
  end

  create_table "budget_transaction_categories", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "budget_id", null: false
    t.datetime "created_at", null: false
    t.integer "transaction_category", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_budget_transaction_categories_on_budget_id"
    t.index ["transaction_category"], name: "index_budget_transaction_categories_on_transaction_category"
  end

  create_table "budgets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", limit: 255, null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "category", default: 0
    t.date "clearing_date"
    t.datetime "created_at", null: false
    t.string "description", limit: 255
    t.string "merchant", limit: 255
    t.text "notes"
    t.boolean "positive", default: false
    t.string "purchased_by", limit: 255
    t.date "transaction_date", null: false
    t.integer "transaction_type", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category"], name: "index_transactions_on_category"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
  end

  add_foreign_key "accounts", "banks"
  add_foreign_key "balances", "accounts"
  add_foreign_key "budget_transaction_categories", "budgets"
  add_foreign_key "transactions", "accounts"
end
