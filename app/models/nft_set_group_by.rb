# See: https://github.com/hive-engine/steemsmartcontracts-wiki/blob/master/NFT-Contracts.md#setgroupby
class NftSetGroupBy < ContractAction
  self.table_name = 'nft_set_group_bys'
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :properties

  def hydrated_properties
    @properties ||= JSON[properties] rescue []
  end
end
