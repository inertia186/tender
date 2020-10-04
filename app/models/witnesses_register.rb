# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Witnesses-Contract#register
class WitnessesRegister < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :ip
  validates_presence_of :rpc_port
  validates_presence_of :p2p_port
  validates_presence_of :signing_key
  validates_presence_of :enabled
  validates_presence_of :recipient, allow_blank: true
  validates_presence_of :amount_steemsbd, allow_blank: true
end
