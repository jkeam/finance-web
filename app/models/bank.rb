class Bank < ApplicationRecord
  validates :name, uniqueness: true
end
