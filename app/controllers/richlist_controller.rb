class RichlistController < ApplicationController
  helper_method :richlist_params
  
  def index
    @start = Time.now
    @per_page = (params[:per_page] || '100').to_i
    @page = (params[:page] || '1').to_i
    @sort_field = (params[:sort_field] || 'total_balance').to_sym
    @sort_order = (params[:sort_order] || 'desc').to_sym
    @symbol = richlist_params.delete(:symbol) || richlist_params.delete(:token_id)
    @token = TokensCreate.find_by!(symbol: @symbol)
    @stake_enabled = TokensEnableStaking.where(symbol: @symbol).any?
    @richlist = []
    
    params.delete(:token_id)
    
    loop do
      sub_list = steem_engine_contracts.find({
        contract: :tokens,
        table: :balances,
        query: {
          symbol: @symbol
        },
        limit: 1000,
        offset: @richlist.size
      })
      sub_list ||= []
      
      break if sub_list.none?
      @richlist += sub_list
    end
    
    @richlist = case @sort_field
    when :account_name
      @richlist.sort_by do |balance|
        balance['account'].downcase
      end
    when :balance
      @richlist.sort_by do |balance|
        balance['balance'].to_f
      end
    when :stake
      @richlist.sort_by do |balance|
        balance['stake'].to_f
      end
    when :pending_unstake
      @richlist.sort_by do |balance|
        balance['pendingUnstake'].to_f
      end
    else
      @richlist.sort_by do |balance|
        balance['balance'].to_f + balance['stake'].to_f + balance['pendingUnstake'].to_f
      end
    end
    
    @richlist = case @sort_order
    when :desc then @richlist.reverse
    else; @richlist
    end
    
    unless params[:format] == 'json'
      @richlist = Kaminari.paginate_array(@richlist).page(@page).per(@per_page)
    end
    
    @elapsed = Time.now - @start
  end
private
  def richlist_params
    params.permit(:token_id, :symbol, :sort_field, :sort_order, :per_page, :page)
  end
end
