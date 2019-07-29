class TransactionSymbol < ApplicationRecord
  belongs_to :trx, foreign_key: 'trx_id', class_name: 'Transaction'
  
  validates_presence_of :symbol
  validates_presence_of :trx_id
  validates_uniqueness_of :symbol, scope: :trx_id
end
