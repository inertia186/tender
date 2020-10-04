# See: https://github.com/hive-engine/steemsmartcontracts-wiki/blob/master/NFT-Contracts.md#removeauthorizedissuingaccounts
class NftRemoveAuthorizedIssuingAccounts < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :symbol
  validates_presence_of :accounts
  
  def hydrated_accounts
    @accounts ||= JSON[accounts] rescue {}
  end
end
