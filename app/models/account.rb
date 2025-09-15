class Account < ApplicationRecord
  validates :name, uniqueness: true
  validates :category, presence: true
  belongs_to :bank
  has_many :transactions
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
