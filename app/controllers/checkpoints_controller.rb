class CheckpointsController < ApplicationController
  helper_method :checkpoints_params
  
  def index
    @start = Time.now
    @checkpoints = Checkpoint.order(created_at: :asc)
    @elapsed = Time.now - @start
  end
private
  def checkpoints_params
    params.permit()
  end
end
