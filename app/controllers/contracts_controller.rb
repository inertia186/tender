class ContractsController < ApplicationController
  helper_method :contracts_params
  
  def index
    @per_page = (contracts_params[:per_page] || '10').to_i
    @page = (contracts_params[:page] || '1').to_i
    @contracts = Transaction.consensus_order(:desc)
    
    @contracts = if !!params[:include_errors]
      @contracts.contract_deploys_or_updates(with_logs_errors: true)
    elsif !!params[:only_errors]
      @contracts.where(is_error: true).where(contract: 'contract').where("action IN ('deploy', 'update')")
    else
      @contracts.contract_deploys_or_updates(with_logs_errors: false)
    end

    @pagy, @contracts = cache ['contracts-index-data', contracts_params, @contracts.count] do
      # Note, we're caching the data here because at this time, there are very
      # few deploy/update records.  Once this becomes a busy aspect of the
      # sidechain, only a view cash will be needed.
      pagy_countless(@contracts, page: @page, items: @per_page)
    end
  end
  
  def show
    @start = Time.now
    @trx_id = contracts_params[:trx_id] || contracts_params[:id]
    @trx = Transaction.find_by_trx_id(@trx_id)
    @contract = ContractUpdate.where(trx: @trx).first
    @contract ||= ContractDeploy.where(trx: @trx).first
    
    # redirect_to contracts_url and return if @contract.nil? && @trx_id != '0'
    
    @contract_name = contracts_params[:contract]
    @contract_name ||= @contract.name if !!@contract
    @contract_name ||= @trx.hydrated_payload['name']
    @elapsed = Time.now - @start
    
    if @trx_id == '0' && @contract.nil?
      # Genesis block is weird, due to "{\"errors\":[\"contract doesn't exist\"]}" weirdness.
      @contract = ContractDeploy.where(name: @contract_name).limit(1).consensus_order.first
    end
    
    # Fall back for contracts that failed to deploy.
    @contract ||= ContractDeploy.new(name: @contract_name, code: @trx.hydrated_payload['code'], trx: @trx)
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
    @b_contract = ContractUpdate.where(name: @contract_name).where(trx: @b_trx).limit(1).consensus_order.first
    @b_contract ||= ContractDeploy.where(name: @contract_name).where(trx: @b_trx).limit(1).consensus_order.first
    
    if @b_trx_id == '0' && @b_contract.nil?
      # Genesis block is weird, due to "{\"errors\":[\"contract doesn't exist\"]}" weirdness.
      @b_contract = ContractDeploy.where(name: @contract_name).limit(1).consensus_order.first
    end
    
    @elapsed = Time.now - @start
  end
private
  def contracts_params
    params.permit(:trx_id, :id, :a_trx_id, :b_trx_id, :account, :symbol,
      :search, :contract, :per_page, :page)
  end
end
