class TransactionsController < ApplicationController
  helper_method :transactions_params
  
  def index
    @per_page = (transactions_params[:per_page] || '100').to_i
    @page = (transactions_params[:page] || '1').to_i
    @keywords = transactions_params[:search].to_s.split(' ').reject(&:empty?)
    @only_errors = params[:only_errors] == 'true'
    @except_errors = params[:except_errors] == 'true'
    @contract = transactions_params[:contract]
    @contract_action = transactions_params[:contract_action]
    @open_orders = transactions_params[:open_orders]
    @transactions = Transaction.consensus_order(:desc)
    
    if !!@only_errors
      @transactions = @transactions.where(is_error: true)
    end
    
    if !!@except_errors
      @transactions = @transactions.where(is_error: false)
    end
    
    if !!transactions_params[:account]
      @transactions = @transactions.with_account(transactions_params[:account])
    end
    
    if !!transactions_params[:symbol]
      symbol = [transactions_params[:symbol]].flatten.compact.map(&:upcase)
      kind = transactions_params[:kind]
      kind = kind.nil? ? nil : kind.to_sym
      @transactions = @transactions.with_symbol(symbol, kind)
      
      # Note, although using the consensus_order scope is more accurate here,
      # during normal operation, when everything is correctly sync'd, :created_at
      # is approximately correct and *much* faster when searching on a symbol.
      
      @transactions = @transactions.except(:order).order(id: :desc)
    end
    
    @token_balance = if !!transactions_params[:account] && !!transactions_params[:symbol]
      result = token_balance(transactions_params)
      
      result.balance if !!result
    end
    
    if @keywords.any?
      if @keywords.size == 1
        keyword = @keywords[0].to_s
        
        if keyword.starts_with? '@'
          redirect_to account_home_url(keyword[1..-1], contract: transactions_params[:contract])
          return
        elsif keyword.starts_with? '$'
          redirect_to transactions_url(symbol: keyword[1..-1], contract: transactions_params[:contract])
          return
        elsif keyword =~ /[a-z]+:[a-z]*/
          c, a = keyword.split(':')
          p = {contract: c}
          p[:contract_action] = a if a.present?
          redirect_to transactions_url(p)
          return
        elsif (trx_id = keyword.split('-')[0]).size == 40
          redirect_to tx_url(trx_id)
          return
        elsif keyword.scan(/\D/).empty? && Transaction.where(block_num: keyword).exists?
          redirect_to b_url(keyword)
          return
        end
      end
      
      @transactions = @transactions.search(keywords: @keywords)
    end
    
    @transactions = @transactions.where(contract: @contract) if !!@contract
    
    @transactions = @transactions.where(action: @contract_action) if !!@contract_action
    
    if !!@open_orders
      open_sells = []
      open_buys = []
      order_params = {
        contract: "market",
        table: "sellBook",
        query: {
        },
        limit: 1000,
        offset: 0,
        indexes: [{"index":"_id","descending":true}]
      }
      
      if !!transactions_params[:account]
        account = [transactions_params[:account]].flatten.compact.map(&:downcase)
        
        if account.size == 1
          order_params[:query][:account] = account[0]
        else
          order_params[:query][:account] = {'$in': account}
        end
      end
      
      if !!transactions_params[:symbol]
        symbol = [transactions_params[:symbol]].flatten.compact.map(&:upcase)
        
        if symbol.size == 1
          order_params[:query][:symbol] = symbol[0]
        else
          order_params[:query][:symbol] = {'$in': symbol}
        end
      end
      
      if (t = engine_contracts.find(order_params.merge(limit: 0, table: 'sellBook'))).nil?
        # FIXME Here, we are guessing which API version (`mongodb` has different indices).
        
        order_params[:indexes] = [{"index":"_id","descending":true}]
      end
      
      while (t = engine_contracts.find(order_params.merge(limit: 1000, table: 'buyBook'))).any?
        open_sells += t
        order_params[:offset] += open_sells.size
      end
      
      order_params[:offset] = 0
      
      while (t = engine_contracts.find(order_params.merge(limit: 1000, table: 'buyBook'))).any?
        open_buys += t
        order_params[:offset] += open_buys.size
      end
      
      trx_ids = open_sells.map{|o| o['txId'].split('-')[0]} + open_buys.map{|o| o['txId'].split('-')[0]}
      
      @transactions = @transactions.where(trx_id: trx_ids)
      @transactions = @transactions.where(contract: 'market').
        where('timestamp >= ?', 30.days.ago)
      @transactions = @transactions.where(action: ['buy', 'sell'])
    end
    
    if params[:format] != 'json'
      @transactions = @transactions.select(fields)
    end
    
    @pagy, @transactions = cache ['transactions-index-data', transactions_params, head_block_num] do
      pagy_countless(@transactions, page: @page, items: @per_page)
    end
  end
  
  def open_orders
    params[:open_orders] = 'true'
    index
    render :index
  end
  
  def show
    @start = Time.now
    @trx_id = transactions_params[:trx_id] || transactions_params[:id]
    @transactions = Transaction.where(trx_id: @trx_id)
    @elapsed = Time.now - @start
  end
private
  def transactions_params
    params.permit(:id, :trx_id, :account, :symbol, :kind, :search, :contract,
      :contract_action, :open_orders, :per_page, :page)
  end
  
  def fields
    [
      :block_num, :trx_id, :sender, :contract, :action, :payload, :logs,
      :is_error, :updated_at, :timestamp
    ]
  end
end
