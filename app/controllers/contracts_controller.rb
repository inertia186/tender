class ContractsController < ApplicationController
  helper_method :contracts_params
  
  def index
    @per_page = (contracts_params[:per_page] || '100').to_i
    @page = (contracts_params[:page] || '1').to_i
    @contracts = Transaction.order(block_num: :desc, trx_in_block: :asc)
    @contracts = @contracts.where(contract: 'contract')
    @contracts = @contracts.where(action: %w(deploy update))
    @contracts = @contracts.paginate(per_page: @per_page, page: @page)
  end
  
  def show
    @start = Time.now
    @trx_id = contracts_params[:trx_id] || contracts_params[:id]
    @trx = Transaction.find_by_trx_id(@trx_id)
    @contract = ContractUpdate.where(trx: @trx).first
    @contract ||= ContractDeploy.where(trx: @trx).first
    
    redirect_to contracts_url and return if @contract.nil? && @trx_id != '0'
    
    @contract_name = contracts_params[:contract] || @contract.name
    @elapsed = Time.now - @start
    
    if @trx_id == '0' && @contract.nil?
      # Genesis block is weird, due to "{\"errors\":[\"contract doesn't exist\"]}" weirdness.
      @contract = ContractDeploy.where(name: @contract_name).limit(1).order(block_num: :asc).first
    end
  end
  
  def diff
    @start = Time.now
    @a_trx_id = contracts_params[:a_trx_id]
    @a_trx = Transaction.find_by_trx_id(@a_trx_id)
    @a_contract = ContractUpdate.where(trx: @a_trx).first
    @a_contract ||= ContractDeploy.where(trx: @a_trx).first
    @contract_name = contracts_params[:contract] || @a_contract.name
    @b_trx_id = contracts_params[:b_trx_id]
    @b_trx = Transaction.find_by_trx_id(@b_trx_id)
    @b_contract = ContractUpdate.where(name: @contract_name).where(trx: @b_trx).limit(1).order(block_num: :asc).first
    @b_contract ||= ContractDeploy.where(name: @contract_name).where(trx: @b_trx).limit(1).order(block_num: :asc).first
    
    if @b_trx_id == '0' && @b_contract.nil?
      # Genesis block is weird, due to "{\"errors\":[\"contract doesn't exist\"]}" weirdness.
      @b_contract = ContractDeploy.where(name: @contract_name).limit(1).order(block_num: :asc).first
    end
    
    @elapsed = Time.now - @start
  end
private
  def contracts_params
    params.permit(:trx_id, :id, :a_trx_id, :b_trx_id, :account, :symbol,
      :search, :contract, :per_page, :page)
  end
end
