class TransactionsController < ApplicationController
  helper_method :transactions_params
  
  def index
    @per_page = (transactions_params[:per_page] || '100').to_i
    @page = (transactions_params[:page] || '1').to_i
    @transactions = Transaction.order(timestamp: :desc)
    
    if !!transactions_params[:account]
      @accounts = [transactions_params[:account]].flatten
      where_clause = (['id IN(?)'] * 6).join(' OR ')
      
      @transactions = @transactions.where(where_clause,
        Transaction.where(sender: @accounts).select(:id),
        TokensIssue.where(to: @accounts).select(:trx_id),
        TokensTransferOwnership.where(to: @accounts).select(:trx_id),
        SscstoreBuy.where(recipient: @accounts).select(:trx_id),
        SteempeggedBuy.where(recipient: @accounts).select(:trx_id),
        SteempeggedRemoveWithdrawal.where(recipient: @accounts).select(:trx_id)
      )
    end
    
    @transactions = @transactions.paginate(per_page: @per_page, page: @page)
  end
  
  def show
    @start = Time.now
    @trx_id = transactions_params[:trx_id] || transactions_params[:id]
    @transactions = Transaction.where(trx_id: @trx_id)
    @elapsed = Time.now - @start
  end
private
  def transactions_params
    params.permit(:id, :trx_id, :account, :per_page, :page)
  end
end
