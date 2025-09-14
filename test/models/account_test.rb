require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "account creation" do
    assert Account.create(name: "test", bank: banks(:one), category: :savings)
  end

  test "bank name must be unique" do
    a = Account.create(name: "test", bank: banks(:one), category: :credit_card)
    assert a.persisted?
    aa = Account.create(name: "test", bank: banks(:one), category: :savings)
    refute aa.persisted?
  end

  test "need type of account" do
    b = Account.create(name: "test", bank: banks(:one))
    refute b.persisted?
  end

  test "need bank" do
    b = Account.create(name: "test", category: :savings)
    refute b.persisted?
  end

  test "can get commercial categories" do
    cc = Account.commercial_categories()
    assert cc.include?(:savings)
    assert cc.include?(:checking)
    assert cc.include?(:money_market)
    assert_equal(3, cc.size)
  end

  test "can test commercial" do
    refute accounts(:one).commercial?
    assert accounts(:three).commercial?
  end
end
