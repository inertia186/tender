# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Nft-Contract#create
class NftCreate < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :name
  validates_presence_of :url, allow_blank: true
  validates_presence_of :authorized_issuing_accounts
  
  validates_uniqueness_of :symbol
  
  def hydrated_authorized_issuing_accounts
    @authorized_issuing_accounts ||= JSON[authorized_issuing_accounts] rescue {}
  end
end
