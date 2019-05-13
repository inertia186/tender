class ContractUpdate < ApplicationRecord
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :name
  validates_presence_of :params, allow_blank: true
  validates_presence_of :code
end
