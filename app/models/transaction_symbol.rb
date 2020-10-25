class TransactionSymbol < ApplicationRecord
  belongs_to :trx, foreign_key: 'trx_id', class_name: 'Transaction'
  
  validates_presence_of :symbol
  validates_presence_of :trx_id
  validates_uniqueness_of :symbol, scope: :trx_id
  
  def self.most_active(limit = 25)
    group(:symbol).order(count_trx_id: :desc).limit(limit).count(:trx_id)
  end
  
  def self.least_active(limit = 25)
    group(:symbol).order(count_trx_id: :asc).limit(limit).count(:trx_id)
  end
end
