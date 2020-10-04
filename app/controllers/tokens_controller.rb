class TokensController < ApplicationController
  helper_method :tokens_params
  
  # See: https://github.com/MattyIce/steem-engine/blob/master/scripts/Config-Prod.js#L11
  DISABLED_SE_TOKENS = %w(BTC LTC STEEM SBD BCC XAP XRP GOLOS DISNEY AMAZON VOICE ETH EOS LASSE TIME R SCTR ALLAH DONE BNB ETHER LTCPEG SBC LASSECASH HIVE TIX TIXM STEM STEMM LEO LEOM LEOMM NEO NEOX PORN SPORTS BATTLE SIM CTP CTPM EMFOUR CC CCCM BEER WEED WEEDM WEEDMM SPACO SPACOM NEOXAG NEOXAGM KANDA SAND INFOWARS ECO EPC SPT JAHM)

  # See: https://github.com/hive-engine/hive-engine-classic/blob/master/scripts/Config-Prod.js#L11
  DISABLED_HE_TOKENS = %w(BTC LTC STEEM SBD BCC XAP XRP GOLOS DISNEY AMAZON VOICE ETH EOS TIME DONE BNB)

  def index
    @per_page = (tokens_params[:per_page] || '10').to_i
    @page = (tokens_params[:page] || '1').to_i
    @tokens = TokensCreate.joins(:trx).includes(:trx)
    @tokens = @tokens.order(Transaction.arel_table[:block_num].asc)
    @tokens = @tokens.where.not(symbol: disabled_tokens)
    @only_stake_enabled = tokens_params[:only_stake_enabled] == 'true'
    @only_scot = tokens_params[:only_scot] == 'true'
    
    if !!tokens_params[:only_stake_enabled]
      @tokens = if @only_stake_enabled
        @tokens.where(symbol: TokensEnableStaking.select(:symbol))
      else
        @tokens.where.not(symbol: TokensEnableStaking.select(:symbol))
      end
    end
    
    if !!tokens_params[:only_scot]
      @tokens = if @only_scot
        @tokens.where(symbol: scot_symbols).
          where(symbol: TokensEnableStaking.select(:symbol))
      else
        @tokens.where.not(symbol: scot_symbols).
          where.not(symbol: TokensEnableStaking.select(:symbol))
      end
    end
    
    @pagy, @tokens = pagy_countless(@tokens, page: @page, items: @per_page)
  end
  
  def show
    @start = Time.now
    @symbol = (tokens_params[:symbol] || tokens_params[:id]).to_s.upcase
    @token = TokensCreate.find_by!(symbol: @symbol)
    @elapsed = Time.now - @start
    @metadata = TokensUpdateMetadata.where(symbol: @token.symbol).first
  end
private
  def tokens_params
    params.permit(:id, :symbol, :per_page, :page, :only_stake_enabled, :only_scot)
  end
  
  def disabled_tokens
    case mainchain.to_sym
    when :steem then DISABLED_SE_TOKENS
    when :hive then DISABLED_HE_TOKENS
    end    
  end
  
  def scot_symbols
    scot_tokens = JSON[open(ENV.fetch('SCOT_API_URL', 'https://scot-api.steem-engine.com') + '/config').read]
    
    case mainchain.to_sym
    when :steem then scot_tokens.map{|t| t['token'] if !t['hive_engine_enabled']}.compact
    when :hive then scot_tokens.map{|t| t['token'] if !!t['hive_engine_enabled']}.compact
    end    
  end
end
