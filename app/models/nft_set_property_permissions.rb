# See: https://github.com/hive-engine/steemsmartcontracts-wiki/blob/master/NFT-Contracts.md#setpropertypermissions
class NftSetPropertyPermissions < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :name
  
  def hydrated_accounts
    @accounts ||= JSON[accounts] rescue []
  end
  
  def hydrated_contracts
    @contracts ||= JSON[contracts] rescue []
  end
end
