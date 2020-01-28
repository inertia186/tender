require 'csv'

class RichlistController < ApplicationController
  helper_method :richlist_params
  
  def index
    @start = Time.now
    @per_page = (params[:per_page] || '100').to_i
    @limit = params[:limit]
    @page = (params[:page] || '1').to_i
    @sort_field = (params[:sort_field] || 'total_balance').to_sym
    @sort_order = (params[:sort_order] || 'desc').to_sym
    @symbol = (richlist_params.delete(:symbol) || richlist_params.delete(:token_id)).to_s.upcase
    @token = TokensCreate.find_by!(symbol: @symbol)
    @stake_enabled = false
    @richlist = []
    @richlist_count
    
    params.delete(:token_id)
    
    @richlist = cache ["richlist-data-#{@symbol}"], expires_in: 15.minutes do
      _richlist = []
      
    loop do
      sub_list = steem_engine_contracts.find({
        contract: :tokens,
        table: :balances,
        query: {
          symbol: @symbol
        },
        limit: @limit || 1000,
          offset: _richlist.size
      })
      sub_list ||= []
      
      break if sub_list.none?
        _richlist += sub_list
      end
      
      _richlist
    end
    
    @richlist_count = @richlist.size
    @total_staked = @richlist.map{|b| b['stake'].to_f || b['delegationsOut'].to_f}.sum
    @total_staked_accounts = @richlist.select{|b| (b['stake'].to_f > 0.0) || (b['delegationsOut'].to_f > 0.0)}.size
    
    @stake_enabled = @total_staked_accounts > 0
    
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
    when :delegations_out
      @richlist.sort_by do |balance|
        balance['delegationsOut'].to_f
      end
    when :delegations_in
      @richlist.sort_by do |balance|
        balance['delegationsIn'].to_f
      end
    when :influence
      @richlist.sort_by do |balance|
        balance['stake'].to_f + balance['delegationsIn'].to_f
      end
    when :owned
      @richlist.sort_by do |balance|
        balance['stake'].to_f + balance['delegationsOut'].to_f
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
    
    @richlist = @richlist.first(@limit) if !!@limit
    
    @elapsed = Time.now - @start
    
    respond_to do |format|
      format.json { }
      format.html {
        @pagy, @richlist = pagy_array(@richlist, page: @page, items: @per_page)
      }
      format.csv do
        csv_data = CSV.generate(headers: true) do |csv|
          csv << %w(account balance stake pendingUnstake delegationsOut delegationsIn)
          
          @richlist.each do |b|
            row = [
              b['account'],
              (b['balance'].to_f rescue 0.0),
              (b['stake'].to_f rescue 0.0),
              (b['pendingUnstake'].to_f rescue 0.0),
              (b['delegationsOut'].to_f rescue 0.0),
              (b['delegationsIn'].to_f rescue 0.0)
            ]
            csv << row
          end
        end

        datestamp = Date.today.strftime("%d%b%Y%H")

        send_data csv_data, type: 'text/csv; charset=iso-8859-1; header=present', disposition: "attachment; filename=richlist-#{@symbol}-#{datestamp}.csv"
      end
    end
  end
private
  def richlist_params
    params.permit(:token_id, :symbol, :sort_field, :sort_order, :per_page, :page)
  end
end
