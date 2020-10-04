# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Witnesses-Contract#proposeRound
class WitnessesProposeRound < ContractAction
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :round
  validates_presence_of :round_hash
  validates_presence_of :signatures
end
