class Bank < ApplicationRecord
  validates :name, uniqueness: true
  has_many :accounts
end
