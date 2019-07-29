# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Tokens-Contract#enablestaking
class TokensEnableStaking < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :unstaking_cooldown
  validates_presence_of :number_transactions
end
