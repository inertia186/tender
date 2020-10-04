# See: https://github.com/hive-engine/steemsmartcontracts/blob/9fe4f9ee775b2a3a9ca1fe581ebf6dc40e5bff28/contracts/nft.js#L48
class NftUpdateParams < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
end
