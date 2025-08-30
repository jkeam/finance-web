require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "transaction creation" do
    t = Transaction.create()
    refute t.persisted?

    t.transaction_date = Date.today
    t.save
    refute t.persisted?

    t.amount_cents = 10000
    t.save
    refute t.persisted?

    t.bank = banks(:one)
    t.save
    assert t.persisted?
  end
end
