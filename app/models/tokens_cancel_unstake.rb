# See: https://github.com/harpagon210/steemsmartcontracts/wiki/Tokens-Contract#cancelunstake
class TokensCancelUnstake < ApplicationRecord
  belongs_to :trx, class_name: 'Transaction', foreign_key: 'trx_id'
  
  validates_presence_of :trx
  validates_presence_of :tx_id
end
