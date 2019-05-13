class Checkpoint < ApplicationRecord
  CHECKPOINT_LENGTH = 10000
  
  validates_presence_of :block_num
  validates_presence_of :block_hash
  validates_presence_of :ref_trx_id
  
  validates_uniqueness_of :block_num
  validates_uniqueness_of :block_hash
  validates_uniqueness_of :ref_trx_id
end
