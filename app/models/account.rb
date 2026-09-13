class Account < ApplicationRecord
  monetize :monthly_contribution_cents, allow_nil: false

  validates :name, uniqueness: true
  validates :category, presence: true
  belongs_to :bank, inverse_of: :accounts
  has_many :transactions, inverse_of: :account, dependent: :destroy
  has_many :balances, inverse_of: :account, dependent: :destroy
  enum :category, {
    savings: 0,
    checking: 1,
    money_market: 2,
    credit_card: 3,
    investment: 4
  }
  enum :tax_treatment, {
    pre_tax: 0,
    roth: 1,
    taxable: 2
  }, prefix: true

  def self.commercial_categories
    %i[savings checking money_market]
  end

  def commercial?
    self.savings? || self.checking? || self.money_market?
  end

  def to_s
    "Name: #{name}, Category: #{category}, Bank: #{bank}"
  end

  def latest_balance_cents
    balances.order(date: :desc).limit(1).pick(:amount_cents) || 0
  end

  # Blends investment balances down to what would actually be spendable after tax:
  # Roth passes through untaxed, pre-tax is haircut at the ordinary-income rate assumed
  # for retirement, taxable brokerage is haircut at the capital gains rate. Accounts with
  # no tax_treatment set are left untouched (0% haircut) so this is a no-op until configured.
  def self.after_tax_investment_summary(pretax_rate:, capital_gains_rate:)
    rate_for = { "pre_tax" => pretax_rate.to_f, "roth" => 0.0, "taxable" => capital_gains_rate.to_f }

    gross_cents = 0
    after_tax_cents = 0

    investment.find_each do |account|
      balance_cents = account.latest_balance_cents
      rate = rate_for[account.tax_treatment] || 0.0
      gross_cents += balance_cents
      after_tax_cents += (balance_cents * (1 - rate)).round
    end

    blended_haircut = gross_cents.zero? ? 0.0 : (1 - (after_tax_cents.to_f / gross_cents))
    { gross_cents: gross_cents, after_tax_cents: after_tax_cents, blended_haircut: blended_haircut }
  end
end
