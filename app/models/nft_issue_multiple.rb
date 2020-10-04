# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Nft-Contract#issue
class NftIssueMultiple < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :instances
  
  def hydrated_instances
    @instances ||= JSON[instances] rescue {}
  end
end
