# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Nft-Contract#addProperty
class NftAddProperty < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :name
  validates_presence_of :property_type
  validates_inclusion_of :is_read_only, in: [true, false]
end
