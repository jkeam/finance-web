class Bank < ApplicationRecord
  validates :name, uniqueness: true
  has_many :accounts, inverse_of: :bank, dependent: :destroy
end
