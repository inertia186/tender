class TokensController < ApplicationController
  helper_method :tokens_params
  
  def index
    @per_page = (tokens_params[:per_page] || '100').to_i
    @page = (tokens_params[:page] || '1').to_i
    @tokens = TokensCreate.joins(:trx).includes(:trx)
    @tokens = @tokens.order(Transaction.arel_table[:timestamp].asc)
    @tokens = @tokens.paginate(per_page: @per_page, page: @page)
    
    @eng_token = if Transaction.any? && @page == 1
      TokensCreate.new(
        id: 0,
        trx: Transaction.find_by(trx_id: '0', trx_in_block: 0),
        symbol: 'ENG',
        name: 'Steem Engine Token',
        url: 'https://steem-engine.com',
        precision: 8,
        max_supply: 9007199254740991,
        updated_at: Time.at(1514793600),
        created_at: Time.at(1514793600)
      )
    end
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
