class NftsController < ApplicationController
  helper_method :nfts_params
  
  # See: https://github.com/MattyIce/steem-engine/blob/master/scripts/Config-Prod.js#L11
  DISABLED_NFTS = %w()

  def index
    
    @per_page = (nfts_params[:per_page] || '10').to_i
    @page = (nfts_params[:page] || '1').to_i
    @nfts = NftCreate.joins(:trx).includes(:trx)
    @nfts = @nfts.order(Transaction.arel_table[:block_num].asc)
    @nfts = @nfts.where('transactions.block_num > ?', contract_deploy_block_num('nft'))
    @nfts = @nfts.where.not(symbol: DISABLED_NFTS)
    @nfts = @nfts.select(fields)
    @pagy, @nfts = pagy_countless(@nfts, page: @page, items: @per_page)
  end
  
  def show
    @start = Time.now
    @symbol = (nfts_params[:symbol] || nfts_params[:id]).to_s.upcase
    @nft = NftCreate.find_by!(symbol: @symbol)
    @elapsed = Time.now - @start
    @properties = NftAddProperty.where(symbol: @nft.symbol)
  end
private
  def nfts_params
    params.permit(:id, :symbol, :per_page, :page)
  end
  
  def fields
    [
      :name, :symbol, :url, :max_supply, :authorized_issuing_accounts,
      :timestamp
    ]
  end
end
