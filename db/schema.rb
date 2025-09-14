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

ActiveRecord::Schema[8.0].define(version: 2025_08_30_014041) do
  create_table "banks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_banks_on_name", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.date "transaction_date", null: false
    t.date "clearing_date"
    t.string "description", limit: 255
    t.string "merchant", limit: 255
    t.integer "category", default: 0
    t.integer "transaction_type", default: 0
    t.string "purchased_by", limit: 255
    t.text "notes"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.boolean "positive", default: false
    t.integer "bank_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_transactions_on_bank_id"
  end

  add_foreign_key "transactions", "banks"
end
