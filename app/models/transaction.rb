class Transaction < ApplicationRecord
  EXECUTED_CODE_HASH_EXCEPTIONS = [
    'contract doesn\'t exist'
  ]
  
  GENESIS_BLOCK = {
    block_num: 0,
    ref_steem_block_num: 0
  }
  
  has_many :market_buys
  has_many :market_cancels
  has_many :market_sells
  has_many :sscstore_buys
  has_many :steempegged_buys
  has_many :steempegged_remove_withdrawals
  has_many :steempegged_withdraws
  has_many :tokens_creates
  has_many :tokens_issues
  has_many :tokens_transfer_ownerships
  has_many :tokens_transfers
  has_many :tokens_update_metadata
  has_many :tokens_update_urls
  
  validates_presence_of :block_num
  validates_presence_of :ref_steem_block_num
  validates_presence_of :trx_id
  validates_presence_of :trx_in_block
  validates_presence_of :sender
  validates_presence_of :contract
  validates_presence_of :action
  validates_presence_of :payload
  validates_presence_of :executed_code_hash, unless: :executed_code_hash_exceptions
  validates_presence_of :hash
  validates_presence_of :database_hash, unless: :database_hash_exceptions
  validates_presence_of :logs
  validates_presence_of :timestamp
  
  validates_uniqueness_of :block_num, scope: %i(trx_id trx_in_block)
  validates_uniqueness_of :trx_in_block, scope: :trx_id
  validates_uniqueness_of :hash
  validates_uniqueness_of :database_hash, scope: %i(trx_id trx_in_block)
  
  after_commit :parse_contract
  
  scope :contract, lambda { |contract, options = {}|
    if !!options[:invert]
      where.not(contract: contract)
    else
      where(contract: contract)
    end
  }
  
  scope :with_logs_errors, -> { where("logs LIKE '%\"errors\":%'") }
  
  def self.meeseeker_ingest(&block)
    pattern = 'steem_engine:*:*:*:*'
    ctx = Redis.new(url: ENV.fetch('MEESEEKER_REDIS_URL', 'redis://127.0.0.1:6379/0'))
    
    ctx.scan_each(match: pattern) do |key|
      n, b, t, i = key.split(':')
      params = JSON[ctx.get(key)]
      trx_id = params['transactionId'].to_s.split('-')[0]
      b = b.to_i
      i = i.to_i
      
      if Transaction.where(block_num: b, trx_id: trx_id, trx_in_block: i).any?
        Rails.logger.warn("Already ingested: #{key} (skipped)")
        ctx.del(key)
        next
      end
      
      transaction = Transaction.create(
        block_num: b,
        trx_id: trx_id,
        trx_in_block: i,
        ref_steem_block_num: params['refSteemBlockNumber'],
        sender: params['sender'],
        contract: params['contract'],
        action: params['action'],
        payload: params['payload'],
        executed_code_hash: params['executedCodeHash'],
        logs: params['logs'],
        timestamp: Time.parse(params['timestamp'] + 'Z'),
        hash: params['hash'],
        database_hash: params['databaseHash'],
      )
      
      if transaction.errors.any?
        # raise "Unable to save #{key}: #{transaction.errors.messages}"
        Rails.logger.warn "Unable to save #{key}: #{transaction.errors.messages}"
        ctx.del(key)
        next
      end
      
      yield transaction, key if !!block
      
      if transaction.persisted?
        ctx.del(key)
      else
        Rails.logger.warn("Did not persist: #{key}")
      end
    end
  end
  
  def hydrated_payload
    @hydrated_payload ||= JSON[payload] rescue {}
  end
  
  def hydrated_logs
    @hydrated_logs ||= JSON[logs] rescue {}
  end
private
  def executed_code_hash_exceptions
    (hydrated_logs['errors'] || [] & EXECUTED_CODE_HASH_EXCEPTIONS).any?
  end
  
  def database_hash_exceptions
    block_num == GENESIS_BLOCK[:block_num]
  end
  
  def parse_contract
    if (hydrated_logs['errors'] || []).any?
      Rails.logger.debug("Ignoring action (trx_id: #{trx_id}): #{contract}.#{action}; errors: #{hydrated_logs['errors'].to_json}")
      
      return
    end
    
    class_name = "#{contract.upcase_first}#{action.upcase_first}"
    klass = begin
      Object.const_get(class_name)
    rescue NameError
      Rails.logger.debug("Unsupported action (trx_id: #{trx_id}): #{contract}.#{action} (no class defined for: #{class_name})")
      
      nil
    end
    
    if !!klass
      params = hydrated_payload
      params.delete('isSignedWithActiveKey')
      params['action_type'] = params.delete('type') if !!params['type']
      params['action_id'] = params.delete('id') if !!params['id']
      params.deep_transform_keys!(&:underscore)
      params.select!{ |k, _v| klass.attribute_names.index(k) }
      
      params = params.map do |k, v|
        case v
        when Hash, Array then [k, v.to_json]
        else; [k, v]
        end
      end.to_h
      
      begin
        klass.create!(params.merge(trx: self))
      rescue ActiveModel::UnknownAttributeError => e
        raise "Unable to create record (trx_id: #{trx_id}): #{contract}.#{action} (caused by: #{e})"
      end
    end
  end
end
