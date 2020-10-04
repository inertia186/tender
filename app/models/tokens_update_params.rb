class TokensUpdateParams < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :token_creation_fee
  validates_presence_of :enable_delegation_fee
  validates_presence_of :enable_staking_fee
end
