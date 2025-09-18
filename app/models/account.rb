class Account < ApplicationRecord
  validates :name, uniqueness: true
  validates :category, presence: true
  belongs_to :bank, inverse_of: :accounts
  has_many :transactions, inverse_of: :account, dependent: :destroy
  has_many :balances, inverse_of: :account, dependent: :destroy
  enum :category, {
    savings: 0,
    checking: 1,
    money_market: 2,
    credit_card: 3
  }

  def self.commercial_categories
    %i[savings checking money_market]
  end

  def commercial?
    self.savings? || self.checking? || self.money_market?
  end
end
