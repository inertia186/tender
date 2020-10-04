class HealthController < ApplicationController
  caches_action :index, expires_in: 3.seconds
  
  def index
    redis_ctx = Redis.new(url: ENV.fetch('MEESEEKER_REDIS_URL', 'redis://127.0.0.1:6379/0'))
    block_num = redis_ctx.get("#{engine_chain_key_prefix}:meeseeker:last_block_num").to_i
    engine_block_num = redis_ctx.get("#{engine_chain_key_prefix}:meeseeker:last_block_num").to_i
    @head_block_num = head_block_num
    @datetime = Time.now
    @engine_head_block_num = nil
    
    @engine_head_block_num = head_block_num
    
    block_num_diff = @head_block_num - block_num
    engine_block_num_diff = @engine_head_block_num - engine_block_num
    external_engine_block_num_diff = @engine_head_block_num - public_head_block_num
    
    @status = 'OK'
    @messages = []
    @messages << "Last engine block_num indexed: #{engine_block_num}; head: #{@engine_head_block_num}; diff: #{engine_block_num_diff}"
    
    if engine_block_num_diff.abs > 48 || external_engine_block_num_diff.abs > 48
      @status = 'ERROR'
      @messages << "Engine blocks too old (time: #{engine_blockchain.latest_block_info['timestamp'] rescue '???'}) (i: #{@engine_head_block_num}; e: #{public_head_block_num})"
    end
    
    if @status == 'ERROR'
      render status: 503
    end
  end
end
