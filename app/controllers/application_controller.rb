class ApplicationController < ActionController::Base
  include Pagy::Backend
  
  helper_method :condenser_api
  helper_method :public_steem_engine_blockchain, :steem_engine_blockchain
  helper_method :public_head_block_num, :head_block_num
  helper_method :replaying?
  helper_method :contract_deploy_block_num
  
  before_action :set_query_only
  after_action :close_agents
private
  def contract_deploy_block_num(contract_name)
    @@contract_deploy_block_num ||= {}
    
    @@contract_deploy_block_num[contract_name] ||= ContractDeploy.where(name: contract_name).joins(:trx).minimum(:block_num) rescue -1
  end
  
  # Nothing should ever be written from any action, so certain PRAGMA
  # assumptions can be made.
  # 
  # See: https://www.sqlite.org/pragma.html#query_only
  def set_query_only
    return if Rails.env.test?
    
    connection = ActiveRecord::Base.connection
    
    case connection.instance_values["config"][:adapter]
    when 'sqlite3'
      connection.execute 'PRAGMA query_only = True'
      connection.execute 'PRAGMA read_uncommitted = True'
      connection.execute 'PRAGMA writable_schema = False'
      connection.execute 'PRAGMA synchronous = OFF'
      connection.execute 'PRAGMA journal_mode = MEMORY'
      connection.execute 'PRAGMA temp_store = MEMORY'
    end
  end
  
  def steem_options
    @steem_options ||= {
      url: ENV.fetch('STEEM_NODE_URL', 'https://api.steemit.com'),
      persist: false
    }
    
    if @steem_options[:failover_urls].nil? && !!ENV['STEEM_NODE_FAILOVER_URLS']
      failover_urls = ENV['STEEM_NODE_FAILOVER_URLS'].split(',')
      
      @steem_options = @steem_options.merge(failover_urls: failover_urls)
    end
    
    @steem_options
  end
    
  def steem_engine_options
    @steem_engine_options ||= {
      root_url: ENV.fetch('STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc'),
      persist: false
    }
  end
  
  def public_steem_engine_options
    @steem_engine_options ||= {
      root_url: ENV.fetch('PUBLIC_STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc'),
      persist: false
    }
  end
  
  def condenser_api
    @condenser_api ||= Radiator::CondenserApi.new(steem_options)
  end
  
  def public_steem_engine_blockchain
    @public_steem_engine_blockchain ||= Radiator::SSC::Blockchain.new(public_steem_engine_options)
  end
  
  def steem_engine_blockchain
    @steem_engine_blockchain ||= Radiator::SSC::Blockchain.new(steem_engine_options)
  end
  
  def steem_engine_contracts
    @steem_engine_contracts ||= Radiator::SSC::Contracts.new(steem_engine_options)
  end
  
  def token_balance(options = {})
    steem_engine_contracts.find_one(
      contract: :tokens,
      table: :balances,
      query: {
        symbol: options[:symbol],
        account: options[:account]
      }
    )
  end
  
  def steem_head_block_num
    condenser_api.get_dynamic_global_properties do |dgpo|
      @datetime = steem_time = Time.parse(dgpo.time + 'Z')
      steem_head_block_num = dgpo.head_block_number
    end
  end
  
  def steem_datetime
    condenser_api.get_dynamic_global_properties do |dgpo|
      steem_time = Time.parse(dgpo.time + 'Z')
    end
  end
  
  def public_head_block_num
    public_steem_engine_blockchain.latest_block_info['blockNumber'] rescue nil || -1
  end
  
  def head_block_num
    @head_block_num ||= Transaction.maximum(:block_num) || -1
  end
  
  def replaying?
    block_num = public_head_block_num
    
    (block_num - Transaction.order(id: :desc).limit(1000).pluck(:block_num).min).abs > 48 ||
    (block_num - head_block_num).abs > 48
  end
  
  def close_agents
    if !!@condenser_api
      Rails.logger.debug { "Closing: #{@condenser_api.inspect}"}
      
      @condenser_api.shutdown
      @condenser_api = nil
    end
    
    if !!@public_steem_engine_blockchain
      Rails.logger.debug { "Closing: #{@public_steem_engine_blockchain.inspect}"}
      
      @public_steem_engine_blockchain.shutdown
      @public_steem_engine_blockchain = nil
    end
    
    if !!@steem_engine_blockchain
      Rails.logger.debug { "Closing: #{@steem_engine_blockchain.inspect}"}
      
      @steem_engine_blockchain.shutdown
      @steem_engine_blockchain = nil
    end
    
    if !!@steem_engine_contracts
      Rails.logger.debug { "Closing: #{@steem_engine_contracts.inspect}"}
      
      @steem_engine_contracts.shutdown
      @steem_engine_contracts = nil
    end
  end
end
