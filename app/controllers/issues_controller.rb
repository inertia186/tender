class IssuesController < ApplicationController
  helper_method :issues_params
  
  def index
    @start = Time.now
    @to = issues_params[:to]
    @symbol = issues_params[:symbol].to_s.upcase
    @per_page = (issues_params[:per_page] || '100').to_i
    @page = (issues_params[:page] || '1').to_i
    @issues = TokensIssue.joins(:trx).includes(:trx).where(to: @to)
    @issues = @issues.where(symbol: @symbol) if @symbol.present? && @symbol != '*'
    @issues = @issues.order(Transaction.arel_table[:block_num].desc)
    @issues = @issues.paginate(per_page: @per_page, page: @page)
    @elapsed = Time.now - @start
  end
private
  def issues_params
    params.permit(:to, :symbol, :per_page, :page)
  end
end
