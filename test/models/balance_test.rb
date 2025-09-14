require "test_helper"

class BalanceTest < ActiveSupport::TestCase
  test "balance creation" do
    assert Balance.create(date: Date.today, amount_cents: 100000, account: accounts(:one))
  end
end
