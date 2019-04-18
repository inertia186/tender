class ApplicationController < ActionController::Base
  helper_method :condenser_api
  helper_method :public_steem_engine_blockchain, :steem_engine_blockchain
  helper_method :public_head_block_num, :head_block_num
  helper_method :replaying?
  
  after_action :close_agents
private
  def condenser_api
    @condenser_api ||= Radiator::CondenserApi.new(url: ENV.fetch('STEEM_NODE_URL', 'https://api.steemit.com'))
  end
  
  def public_steem_engine_blockchain
    @public_steem_engine_blockchain ||= Radiator::SSC::Blockchain.new(root_url: 'https://api.steem-engine.com/rpc')
  end
  
  def steem_engine_blockchain
    @steem_engine_blockchain ||= Radiator::SSC::Blockchain.new(root_url: ENV.fetch('STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc'))
  end
  
  def steem_engine_contracts
    @steem_engine_contracts ||= Radiator::SSC::Contracts.new(root_url: ENV.fetch('STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc'))
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
  
  def public_head_block_num
    public_steem_engine_blockchain.latest_block_info['blockNumber'] rescue nil || -1
  end
  
  def head_block_num
    @head_block_num ||= Transaction.maximum(:block_num) || -1
  end
  
  def replaying?
    (public_head_block_num - head_block_num).abs > 48
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
