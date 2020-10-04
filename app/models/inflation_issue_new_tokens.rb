# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Inflation-Contract#issueNewTokens
class InflationIssueNewTokens < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
end
