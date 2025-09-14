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
end
