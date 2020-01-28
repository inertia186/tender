require 'active_record/validations'

class Transaction < ApplicationRecord
  EXECUTED_CODE_HASH_EXCEPTIONS = [
    'contract doesn\'t exist'
  ]
  
  GENESIS_BLOCK = {
    block_num: 0,
    ref_steem_block_num: 0
  }
  
  VIRTUAL_TRX_ID = '0000000000000000000000000000000000000000'
  
  NFT_CONTRACTS = %i(nft nftmarket)
  
  with_options foreign_key: 'trx_id', dependent: :destroy do |trx|
    trx.has_many :contract_deploys
    trx.has_many :contract_updates
    trx.has_many :market_buys
    trx.has_many :market_cancels
    trx.has_many :market_sells
    trx.has_many :sscstore_buys
    trx.has_many :steempegged_buys
    trx.has_many :steempegged_remove_withdrawals
    trx.has_many :steempegged_withdraws
    trx.has_many :tokens_cancel_unstakes
    trx.has_many :tokens_check_pending_unstakes, class_name: 'TokensCheckPendingUnstakes'
    trx.has_many :tokens_creates
    trx.has_many :tokens_delegates
    trx.has_many :tokens_enable_delegations
    trx.has_many :tokens_enable_stakings
    trx.has_many :tokens_issues
    trx.has_many :tokens_stakes
    trx.has_many :tokens_transfer_ownerships
    trx.has_many :tokens_transfer_to_contracts
    trx.has_many :tokens_transfers
    trx.has_many :tokens_undelegates
    trx.has_many :tokens_unstakes
    trx.has_many :tokens_update_metadata, class_name: 'TokensUpdateMetadata'
    trx.has_many :tokens_update_params, class_name: 'TokensUpdateParams'
    trx.has_many :tokens_update_precisions
    trx.has_many :tokens_update_urls
    trx.has_many :nft_add_properties
    trx.has_many :nft_creates
    trx.has_many :nft_issues
    trx.has_many :nft_update_metadata, class_name: 'nftUpdateMetadata'
    trx.has_many :nft_update_names
    trx.has_many :nftmarket_enable_markets
  end
  
  has_many :transaction_accounts, foreign_key: 'trx_id', dependent: :destroy
  has_many :transaction_symbols, foreign_key: 'trx_id', dependent: :destroy
  
  validates_presence_of :block_num
  validates_presence_of :ref_steem_block_num
  validates_presence_of :trx_id
  validates_presence_of :trx_in_block
  validates_presence_of :sender
  validates_presence_of :contract
  validates_presence_of :action
  validates_presence_of :payload, unless: :virtual?
  validates_presence_of :executed_code_hash, unless: :executed_code_hash_exceptions
  validates_presence_of :hash
  validates_presence_of :database_hash, unless: :database_hash_exceptions
  validates_presence_of :logs
  validates_presence_of :timestamp
  
  validates_uniqueness_of :block_num, scope: %i(trx_id trx_in_block)
  validates_uniqueness_of :trx_in_block, scope: :trx_id, unless: :virtual?
  validates_uniqueness_of :hash
  validates_uniqueness_of :database_hash, scope: %i(trx_id trx_in_block)
  
  before_validation :parse_error, on: :create
  after_commit :parse_contract, on: :create
  
  scope :consensus_order, lambda { |consensus_order = :asc|
    order(block_num: consensus_order, trx_in_block: consensus_order == :asc ? :desc : :asc, trx_id: consensus_order)
  }
  
  scope :contract, lambda { |contract, options = {}|
    if !!options[:invert]
      where.not(contract: contract)
    else
      where(contract: contract)
    end
  }
  
  scope :with_logs_errors, lambda { |with_logs_errors = true|
    where(is_error: with_logs_errors)
  }
  
  scope :with_account, lambda { |account = nil|
    where(id: TransactionAccount.where(account: account).select(:trx_id))
  }
  
  scope :with_symbol, lambda { |symbol = nil, kind = nil|
    r = case kind
    when :token then where.not(contract: NFT_CONTRACTS)
    when :nft then where(contract: NFT_CONTRACTS)
    else; all
    end
    
    r.where(id: TransactionSymbol.where(symbol: symbol).select(:trx_id))
  }
  
  scope :search, lambda { |options = {}|
    keywords = [options[:keywords]].flatten.compact.map(&:downcase)
    keywords = keywords.map { |keyword| "%#{keyword}%"}
    
    where_clause = keywords.map do |keyword|
      <<~DONE
        block_num LIKE ? OR
        ref_steem_block_num LIKE ? OR
        trx_id LIKE ? OR
        sender LIKE ? OR
        contract LIKE ? OR
        action LIKE ? OR
        LOWER(payload) LIKE ? OR
        LOWER(logs) LIKE ? OR
        executed_code_hash LIKE ? OR
        hash LIKE ? OR
        database_hash LIKE ? OR
        timestamp LIKE ?
      DONE
    end
    
    where(where_clause.join(' OR '), *keywords * 12)
  }
  
  scope :virtual, lambda { |virtual = true|
    if virtual
      where(trx_id: VIRTUAL_TRX_ID)
    else
      where.not(trx_id: VIRTUAL_TRX_ID)
    end
  }
  
  scope :contract_deploys_or_updates, lambda { |options = {with_logs_errors: false}|
    contract_deploys = ContractDeploy.select(:trx_id)
    contract_updates = ContractUpdate.select(:trx_id)
    r = where(contract: 'contract').where("action IN ('deploy', 'update')")
    
    if !!options[:with_logs_errors]
      r = r.where("transactions.id IN(?) OR transactions.id IN(?) OR (transactions.id NOT IN(?) AND transactions.id NOT IN(?) AND is_error = true)", contract_deploys, contract_updates, contract_deploys, contract_updates)
    else
      r = r.where("transactions.id IN(?) OR transactions.id IN(?)", contract_deploys, contract_updates)
    end
  }
  
  def self.meeseeker_ingest(max_transactions = -1, &block)
    pattern = 'steem_engine:*:*:*:*'
    ctx = Redis.new(url: ENV.fetch('MEESEEKER_REDIS_URL', 'redis://127.0.0.1:6379/0'))
    processed = 0
    
    ctx.scan_each(match: pattern) do |key|
      break if max_transactions > -1 && processed >= max_transactions
      
      n, b, t, i = key.split(':')
      params = JSON[ctx.get(key)]
      trx_id = params['transactionId'].to_s.split('-')[0]
      b = b.to_i
      i = i.to_i
      
      if Transaction.where(block_num: b, trx_id: trx_id, trx_in_block: i).exists?
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
      
      unless transaction.persisted?
        Rails.logger.warn("Did not persist: #{key}")
      end
      
      processed = processed + 1
    end
  end
  
  def to_param
    if trx_in_block == 0
      "#{trx_id}"
    else
      "#{trx_id}-#{trx_in_block}"
    end
  end
  
  def virtual?
    trx_id == VIRTUAL_TRX_ID
  end
  
  def hydrated_payload
    @hydrated_payload ||= JSON[payload] rescue {}
  end
  
  def hydrated_logs
    @hydrated_logs ||= JSON[logs] rescue {}
  end
  
  def add_account(account)
    return if account.nil?
    return if transaction_accounts.where(account: account).exists?
    
    transaction_accounts.create(account: account)
  end
  
  def add_symbol(symbol)
    return if symbol.nil?
    return if transaction_symbols.where(symbol: symbol).exists?
    
    transaction_symbols.create(symbol: symbol)
  end
private
  def executed_code_hash_exceptions
    is_error? && (hydrated_logs['errors'] || [] & EXECUTED_CODE_HASH_EXCEPTIONS).any?
  end
  
  def database_hash_exceptions
    block_num == GENESIS_BLOCK[:block_num]
  end
  
  def parse_error
    self.is_error = (hydrated_logs['errors'] || []).any?
  end
  
  def parse_contract
    if is_error?
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
      params['action_type'] = params.delete('type') if contract == 'market' && action == 'cancel' && !!params['type']
      params['property_type'] = params.delete('type') if contract == 'nft' && action == 'addProperty' && !!params['type']
      params['action_id'] = params.delete('id') if !!params['id']
      params['tx_id'] = params.delete('txID') if !!params['txID']
      params['amount_steemsbd'] = params.delete('amountSTEEMSBD') if !!params['amountSTEEMSBD']
      params['memo'] = params['memo'].to_s if params.keys.include? "memo"
      params['p2p_port'] = params.delete('P2PPort') if !!params['P2PPort']
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
      rescue => e
        Rails.logger.error("Unable to create record (trx_id: #{trx_id}): #{contract}.#{action} (params: #{params}) (caused by: #{e})")
      end
    end
  end
end
