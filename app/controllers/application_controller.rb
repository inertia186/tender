class ApplicationController < ActionController::Base
  helper_method :public_steem_engine_blockchain, :steem_engine_blockchain
  helper_method :head_block_num
  helper_method :replaying?
  
  def public_steem_engine_blockchain
    @public_steem_engine_blockchain ||= Radiator::SSC::Blockchain.new(root_url: 'https://api.steem-engine.com/rpc')
  end
  
  def steem_engine_blockchain
    @steem_engine_blockchain ||= Radiator::SSC::Blockchain.new(root_url: ENV.fetch('STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc'))
  end
  
  def head_block_num
    @head_block_num ||= Transaction.maximum(:block_num) || -1
  end
  
  def replaying?
    start = Time.now
    replaying = session[:replaying?]
    replaying_checked_at = session[:replaying_checked_at]
    replaying_checked_at = Time.parse(replaying_checked_at) if !!replaying_checked_at
    
    if replaying.nil? || replaying_checked_at.nil? || ( Time.now - replaying_checked_at > 300 )
      latest_block_num = public_steem_engine_blockchain.latest_block_info['blockNumber']
    
      replaying = session[:replaying?] = (latest_block_num - head_block_num).abs > 48
      session[:replaying_checked_at] = start
    end
    
    Rails.logger.debug { "Replay detection elapsed: %.3f" % (Time.now - start) }
  
    replaying
  end
end
