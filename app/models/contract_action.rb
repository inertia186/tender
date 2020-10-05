class ContractAction < ApplicationRecord
  self.abstract_class = true
  
  scope :consensus_order, lambda { |consensus_order = :asc|
    joins(:trx).order(block_num: consensus_order, trx_in_block: consensus_order == :asc ? :desc : :asc, trx_id: consensus_order)
  }
  
  after_commit do |obj|
    trx.add_account(obj.trx.sender)
    trx.add_account(obj.from) if obj.respond_to? :from
    trx.add_account(obj.to) if obj.respond_to? :to
    trx.add_account(obj.recipient) if obj.respond_to? :recipient
    trx.add_symbol(obj.symbol) if obj.respond_to? :symbol
    trx.add_symbol(obj.witness) if obj.respond_to? :witness
    
    if obj.respond_to? :authorized_issuing_accounts
      (JSON[obj.authorized_issuing_accounts] rescue []).each do |a|
        trx.add_account(a)
      end
    end
    
    # TODO inspect things like nfts field
    # TODO inspect logs.event fields for "side-effect" actions
    
    if !!obj.trx.logs
      if !!obj.trx.hydrated_logs['events']
        obj.trx.hydrated_logs['events'].each do |event|
          next if event['data'].nil?
          
          # Most of these will be token events.
          
          trx.add_account(event['data']['account'])
          
          # Most of these will be market events.
          
          trx.add_account(event['data']['from'])
          trx.add_account(event['data']['to'])
          trx.add_symbol(event['data']['price_symbol'])
          
          # Various events.
          
          trx.add_symbol(event['data']['symbol'])
        end
      end
    end
  end
end
