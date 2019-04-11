class TokensController < ApplicationController
  helper_method :tokens_params
  
  def index
    @per_page = (tokens_params[:per_page] || '100').to_i
    @page = (tokens_params[:page] || '1').to_i
    @tokens = TokensCreate.order(timestamp: :desc)
    
    @tokens = @tokens.paginate(per_page: @per_page, page: @page)
  end
  
  def show
    @start = Time.now
    @symbol = tokens_params[:symbol] || tokens_params[:id]
    @token = TokensCreate.find_by!(symbol: @symbol)
    @elapsed = Time.now - @start
  end
private
  def tokens_params
    params.permit(:id, :symbol, :per_page, :page)
  end
end
