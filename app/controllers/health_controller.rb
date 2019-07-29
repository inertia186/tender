class HealthController < ApplicationController
  def index
    redis_ctx = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0'))
    steem_block_num = redis_ctx.get('steem:meeseeker:last_block_num').to_i
    steem_engine_block_num = redis_ctx.get('steem_engine:meeseeker:last_block_num').to_i
    steem_time = nil
    @steem_head_block_num = nil
    @steem_engine_head_block_num = nil
    
    condenser_api.get_dynamic_global_properties do |dgpo|
      @datetime = steem_time = Time.parse(dgpo.time + 'Z')
      @steem_head_block_num = dgpo.head_block_number
    end
    
    @steem_engine_head_block_num = Transaction.distinct(:block_num).count(:block_num) - 1
    
    steem_block_num_diff = @steem_head_block_num - steem_block_num
    steem_engine_block_num_diff = @steem_engine_head_block_num - steem_engine_block_num
    external_steem_engine_block_num_diff = @steem_engine_head_block_num - public_head_block_num
    
    @status = 'OK'
    @messages = []
    @messages << "Last steem engine block_num indexed: #{steem_engine_block_num}; head: #{@steem_engine_head_block_num}; diff: #{steem_engine_block_num_diff}"
    
    if steem_engine_block_num_diff.abs > 48 || external_steem_engine_block_num_diff.abs > 48
      @status = 'ERROR'
      @messages << "Steem Engine blocks too old (time: #{steem_engine_blockchain.latest_block_info['timestamp'] rescue '???'}) (i: #{@steem_engine_head_block_num}; e: #{public_head_block_num})"
    end
    
    if @status == 'ERROR'
      render status: 503
    end
  end
end
