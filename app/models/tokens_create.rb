# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Tokens-Contract#create
class TokensCreate < ApplicationRecord
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :name
  validates_presence_of :precision
  validates_presence_of :max_supply
  
  validates_uniqueness_of :symbol
end
