# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Nft-Contract#issue
class NftIssue < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :to
  validates_presence_of :fee_symbol
  validates_presence_of :lock_tokens
  validates_presence_of :properties
  
  def hydrated_lock_tokens
    @lock_tokens ||= JSON[lock_tokens] rescue {}
  end
  
  def hydrated_properties
    @hydrated_properties ||= JSON[properties] rescue {}
  end
end
