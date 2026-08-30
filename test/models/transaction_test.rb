require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "transaction creation" do
    t = Transaction.create()
    refute t.persisted?

    t.transaction_date = Date.today()
    t.save
    refute t.persisted?

    t.amount_cents = 10000
    t.save
    refute t.persisted?

    t.account = accounts(:one)
    t.save
    assert t.persisted?
  end

  test "get spending" do
    transactions = Transaction.spending()
    assert 2, transactions.size
    assert :type_purchase, transactions[0].transaction_type
    assert :type_purchase, transactions[1].transaction_type
  end

  test "get income" do
    transactions = Transaction.income()
    assert 1, transactions.size()
    assert :type_credit, transactions[0].transaction_type
  end

  test "spending baseline annualizes spend over the date range" do
    baseline = Transaction.spending_baseline(Date.new(2025, 8, 1), Date.new(2025, 9, 1))

    assert_equal 1_440_000, baseline[:annual_cents]
    assert_equal 0, baseline[:needs_annual_cents]
    assert_equal 1_440_000, baseline[:wants_annual_cents]
    assert_equal 120_000, baseline[:monthly_avg_cents]
  end

  test "income and spending by month includes a savings rate series" do
    result = Transaction.income_and_spending_by_month(Date.new(2025, 8, 1), Date.new(2025, 9, 1))

    month_key = Date.new(2025, 8, 1)
    assert_equal(-20_000, result[:income_per_month][month_key])
    assert_equal 1_200, result[:spend_per_month][month_key]
    assert_equal 106.0, result[:savings_rate_by_month][month_key]
  end
end
