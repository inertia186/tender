class TransactionsController < ApplicationController
  helper_method :transactions_params
  
  def index
    @per_page = (transactions_params[:per_page] || '100').to_i
    @page = (transactions_params[:page] || '1').to_i
    @transactions = Transaction.order(timestamp: :desc)
    
    if !!transactions_params[:account]
      @accounts = [transactions_params[:account]].flatten
      
      trx_ids = Transaction.where(sender: @accounts).limit(1000).order(timestamp: :desc).pluck(:trx_id)
      trx_ids += TokensIssue.where(to: @accounts).limit(1000).order(timestamp: :desc).pluck(:trx_id)
      trx_ids += TokensTransferOwnership.where(to: @accounts).limit(1000).order(timestamp: :desc).pluck(:trx_id)
      trx_ids += SscstoreBuy.where(recipient: @accounts).limit(1000).order(timestamp: :desc).pluck(:trx_id)
      trx_ids += SteempeggedBuy.where(recipient: @accounts).limit(1000).order(timestamp: :desc).pluck(:trx_id)
      trx_ids += SteempeggedRemoveWithdrawal.where(recipient: @accounts).limit(1000).order(timestamp: :desc).pluck(:trx_id)
      
      @transactions = @transactions.where("trx_id IN(?)", trx_ids)
    end
    
    @transactions = @transactions.paginate(per_page: @per_page, page: @page)
  end
  
  def show
    @start = Time.now
    @trx_id = transactions_params[:trx_id] || transactions_params[:id]
    @transaction = Transaction.find_by!(trx_id: @trx_id)
    @elapsed = Time.now - @start
  end
private
  def transactions_params
    params.permit(:id, :trx_id, :account, :per_page, :page)
  end
end
