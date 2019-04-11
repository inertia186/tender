class SteempeggedRemoveWithdrawal < ApplicationRecord
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id', primary_key: 'trx_id'
  
  validates_presence_of :trx_id
  validates_presence_of :action_id
  validates_presence_of :recipient
  validates_presence_of :amount_steemsbd
end
