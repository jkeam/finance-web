require "test_helper"

class BankTest < ActiveSupport::TestCase
  test "bank creation" do
    assert Bank.create(name: 'test')
  end
  test "bank name must be unique" do
    b = Bank.create(name: 'test')
    assert b.persisted?
    bb = Bank.create(name: 'test')
    refute bb.persisted?
  end
  test "default bank type is commercial" do
    b = Bank.create(name: 'test')
    assert b.persisted?
    assert b.commercial?
  end
end
