class Bank < ApplicationRecord
  validates :name, uniqueness: true
  has_many :accounts, inverse_of: :bank, dependent: :destroy

  def to_s
    "Name: #{name}"
  end
end
