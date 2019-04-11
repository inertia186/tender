class BlocksController < ApplicationController
  helper_method :blocks_params
  
  def show
    @start = Time.now
    @block_num = (blocks_params[:block_num] || blocks_params[:id]).to_i
    @block = steem_engine_blockchain.block_info(@block_num)
    @elapsed = Time.now - @start
  end
private
  def blocks_params
    params.permit(:block_num, :id)
  end
end
