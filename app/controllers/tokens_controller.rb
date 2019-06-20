class TokensController < ApplicationController
  helper_method :tokens_params
  
  # See: https://github.com/MattyIce/steem-engine/blob/9f52238f07ddf6d6c48694abab5ef3fe8330c786/scripts/Config-Prod.js#L10
  DISABLED_TOKENS = %w(BTC STEEM SBD BCC XAP)
  
  def index
    @per_page = (tokens_params[:per_page] || '10').to_i
    @page = (tokens_params[:page] || '1').to_i
    @tokens = TokensCreate.joins(:trx).includes(:trx)
    @tokens = @tokens.order(Transaction.arel_table[:timestamp].asc)
    @tokens = @tokens.where.not(symbol: DISABLED_TOKENS)
    @tokens = @tokens.paginate(per_page: @per_page, page: @page)
    
    if !!params[:only_stake_enabled]
      @tokens = if params[:only_stake_enabled] == 'true'
        @tokens.where(symbol: TokensEnableStaking.select(:symbol))
      else
        @tokens.where.not(symbol: TokensEnableStaking.select(:symbol))
      end
    end
    
    if !!params[:only_scot]
      scot_tokens = JSON[open(ENV.fetch('SCOT_API_URL', 'https://scot-api.steem-engine.com') + '/config').read]
      scot_symbols = scot_tokens.map{|token| token['token']}
      
      @tokens = if params[:only_scot] == 'true'
        @tokens.where(symbol: scot_symbols).
          where(symbol: TokensEnableStaking.select(:symbol))
      else
        @tokens.where.not(symbol: scot_symbols).
          not(symbol: TokensEnableStaking.select(:symbol))
      end
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
