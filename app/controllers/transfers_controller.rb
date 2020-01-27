class TransfersController < ApplicationController
  helper_method :transfers_params
  
  def index
    @start = Time.now
    @from = transfers_params[:from]
    @to = transfers_params[:to]
    @symbol = transfers_params[:symbol].to_s.upcase
    @per_page = (transfers_params[:per_page] || '100').to_i
    @page = (transfers_params[:page] || '1').to_i
    @transfers = TokensTransfer.joins(:trx).includes(:trx)
    @transfers = @transfers.where('transactions.sender = ?', @from) if !!@from
    @transfers = @transfers.where(to: @to) if !!@to
    @transfers = @transfers.where(symbol: @symbol) if @symbol.present? && @symbol != '*'
    @transfers = @transfers.order(Transaction.arel_table[:block_num].desc)
    @pagy, @transfers = pagy_countless(@transfers, page: @page, items: @per_page)
    @elapsed = Time.now - @start
  end
private
  def transfers_params
    params.permit(:from, :to, :symbol, :per_page, :page)
  end
end
