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
    (public_steem_engine_blockchain.latest_block_info['blockNumber'] - head_block_num).abs > 48
  end
end
