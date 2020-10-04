# See: https://github.com/harpagon210/steemsmartcontracts-wiki/blob/master/NFT-Market-Contract.md#cancel
class NftmarketCancel < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :nfts
  
  def hydrated_nfts
    @nfts ||= JSON[nfts] rescue []
  end
end