class TransactionAccount < ApplicationRecord
  belongs_to :trx, foreign_key: 'trx_id', class_name: 'Transaction'
  
  validates_presence_of :account
  validates_presence_of :trx_id
  validates_uniqueness_of :account, scope: :trx_id
end
