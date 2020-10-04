# See: https://github.com/hive-engine/steemsmartcontracts/blob/9fe4f9ee775b2a3a9ca1fe581ebf6dc40e5bff28/contracts/tokens.js#L553
class TokensTransferFromContract < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :from
  validates_presence_of :quantity
  validates_presence_of :transfer_type
end
