class TransactionsController < ApplicationController
  helper_method :transactions_params
  
  def index
    @per_page = (transactions_params[:per_page] || '100').to_i
    @page = (transactions_params[:page] || '1').to_i
    @keywords = transactions_params[:search].to_s.split(' ').reject(&:empty?)
    @transactions = Transaction.order(timestamp: :desc, trx_in_block: :asc)
    
    if !!transactions_params[:account]
      @transactions = @transactions.with_account(transactions_params[:account])
    end
    
    if !!transactions_params[:symbol]
      @transactions = @transactions.with_symbol(transactions_params[:symbol])
    end
    
    if @keywords.any?
      if @keywords.size == 1
        keyword = @keywords[0]
        
        if keyword.starts_with? '@'
          redirect_to account_home_url(keyword[1..-1])
          return
        elsif keyword.size == 40
          redirect_to tx_url(keyword)
          return
        elsif keyword.scan(/\D/).empty? && Transaction.where(block_num: keyword).any?
          redirect_to b_url(keyword)
          return
        end
      end
      
      @transactions = @transactions.search(keywords: @keywords)
    end
    
    @transactions = @transactions.select(fields)
    
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
    params.permit(:id, :trx_id, :account, :symbol, :search, :per_page, :page)
  end
  
  def fields
    [
      :block_num, :trx_id, :sender, :contract, :action, :payload, :logs, :updated_at,
      :timestamp
    ]
  end
end
