class CreateInitialSchema < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :block_num, null: false
      t.integer :ref_steem_block_num, null: false
      t.string :trx_id, null: false
      t.integer :trx_in_block, null: false
      t.string :sender, null: false
      t.string :contract, null: false
      t.string :action, null: false
      t.text :payload, null: false
      t.string :executed_code_hash, null: false
      t.string :hash, null: false
      t.string :database_hash, null: false
      t.text :logs, null: false
      t.datetime :timestamp, null: false
      t.timestamps null: false
    end
    
    add_index :transactions, :hash, unique: true, name: 'transactions-by-hash'
    add_index :transactions, %i(block_num trx_id trx_in_block), unique: true, name: 'transactions-by-block_num-trx_id-trx_in_block'
    add_index :transactions, %i(trx_id trx_in_block), name: 'transactions-by-trx_id-trx_in_block'
    add_index :transactions, %i(database_hash trx_id trx_in_block), unique: true, name: 'transactions-by-database_hash-trx_id-trx_in_block'
    
    add_index :transactions, %i(block_num trx_id trx_in_block sender contract action timestamp), name: 'transactions-by-trx_id-trx_in_block-sender-contract-action-ti'
    add_index :transactions, %i(trx_in_block timestamp), name: 'transactions-by-trx_in_block-timestamp'
    
    create_table :contract_deploys do |t|
      t.integer :trx_id, null: false
      t.string :name, null: false
      t.string :params, null: false
      t.text :code, null: false
      t.timestamps null: false
    end
    
    add_index :contract_deploys, %i(trx_id name), name: 'contract_deploys-by-trx_id-name'
    
    create_table :contract_updates do |t|
      t.integer :trx_id, null: false
      t.string :name, null: false
      t.string :params, null: false
      t.text :code, null: false
      t.timestamps null: false
    end
    
    add_index :contract_updates, %i(trx_id name), name: 'contract_updates-by-trx_id-name'
    
    create_table :tokens_issues do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.string :quantity, null: false
      t.string :memo, null: false, default: ''
      t.timestamps null: false
    end
    
    add_index :tokens_issues, %i(trx_id symbol), name: 'tokens_issues-by-trx_id-symbol'
    add_index :tokens_issues, %i(trx_id symbol to), name: 'tokens_issues-by-trx_id-symbol-to'
    
    create_table :tokens_transfers do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.string :quantity, null: false
      t.string :memo, null: false, default: ''
      t.timestamps null: false
    end
    
    add_index :tokens_transfers, %i(trx_id symbol), name: 'tokens_transfers-by-trx_id-symbol'
    add_index :tokens_transfers, %i(trx_id symbol to), name: 'tokens_transfers-by-trx_id-symbol-to'
    
    create_table :tokens_creates do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :name, null: false
      t.string :url, null: false, default: ''
      t.integer :precision, null: false
      t.integer :max_supply, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_creates, :symbol, unique: true, name: 'tokens_creates-by-symbol'
    add_index :tokens_creates, %i(trx_id symbol), name: 'tokens_creates-by-trx_id-symbol'

    create_table :tokens_transfer_ownerships do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.timestamps null: false
    end

    add_index :tokens_transfer_ownerships, %i(trx_id symbol), name: 'tokens_transfer_ownerships-by-trx_id-symbol'
    
    create_table :tokens_update_metadata do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :metadata, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_update_metadata, %i(trx_id symbol), name: 'tokens_update_metadata-by-trx_id-symbol'
    
    create_table :tokens_update_urls do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :url, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_update_urls, %i(trx_id symbol), name: 'tokens_update_urls-by-trx_id-symbol'
    
    create_table :tokens_enable_stakings do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.integer :unstaking_cooldown, null: false
      t.integer :number_transactions, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_enable_stakings, %i(trx_id symbol), name: 'tokens_enable_stakings-by-trx_id-symbol'
    
    create_table :tokens_update_params do |t|
      t.integer :trx_id, null: false
      t.text :token_creation_fee, null: false
      t.timestamps null: false
    end
    
    create_table :tokens_stakes do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_stakes, %i(trx_id symbol), name: 'tokens_stakes-by-trx_id-symbol'
    
    create_table :tokens_unstakes do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_unstakes, %i(trx_id symbol), name: 'tokens_unstakes-by-trx_id-symbol'
    
    create_table :tokens_cancel_unstakes do |t|
      t.integer :trx_id, null: false
      t.string :tx_id, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_cancel_unstakes, %i(trx_id), name: 'tokens_cancel_unstakes-by-trx_id'
    add_index :tokens_cancel_unstakes, %i(trx_id tx_id), name: 'tokens_cancel_unstakes-by-trx_id-tx_id'
    
    create_table :tokens_check_pending_unstakes do |t|
      t.integer :trx_id, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_check_pending_unstakes, %i(trx_id), name: 'tokens_check_pending_unstakes-by-trx_id'
    
    create_table :tokens_delegates do |t|
      t.integer :trx_id, null: false
      t.string :to, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_delegates, %i(trx_id), name: 'tokens_delegates-by-trx_id'
    add_index :tokens_delegates, %i(trx_id to symbol), name: 'tokens_delegates-by-to-symbol'
    
    create_table :tokens_enable_delegations do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.integer :undelegation_cooldown, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_enable_delegations, %i(trx_id), name: 'tokens_enable_delegations-by-trx_id'
    add_index :tokens_enable_delegations, %i(trx_id to symbol), name: 'tokens_enable_delegations-by-symbol'
    
    create_table :tokens_transfer_to_contracts do |t|
      t.integer :trx_id, null: false
      t.string :to, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_transfer_to_contracts, %i(trx_id), name: 'tokens_transfer_to_contracts-by-trx_id'
    add_index :tokens_transfer_to_contracts, %i(trx_id to symbol), name: 'tokens_transfer_to_contracts-by-to-symbol'
    
    create_table :tokens_undelegates do |t|
      t.integer :trx_id, null: false
      t.string :from, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_undelegates, %i(trx_id), name: 'tokens_undelegates-by-trx_id'
    add_index :tokens_undelegates, %i(trx_id from symbol), name: 'tokens_undelegates-by-from-symbol'
    
    create_table :tokens_update_precisions do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.integer :precision, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_update_precisions, %i(trx_id), name: 'tokens_update_precisions-by-trx_id'
    add_index :tokens_update_precisions, %i(trx_id to symbol), name: 'tokens_update_precisions-by-to-symbol'
    
    create_table :market_buys do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.string :price, null: false
      t.timestamps null: false
    end
    
    add_index :market_buys, %i(trx_id symbol), name: 'market_buys-by-trx_id-symbol'
    
    create_table :market_sells do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.string :price, null: false
      t.timestamps null: false
    end
    
    add_index :market_sells, %i(trx_id symbol), name: 'market_sells-by-trx_id-symbol'
    
    create_table :market_cancels do |t|
      t.integer :trx_id, null: false
      t.string :action_type, null: false
      t.string :action_id, null: false
      t.timestamps null: false
    end
    
    add_index :market_cancels, %i(trx_id action_type action_id), name: 'market_cancels-by-trx_id-action_type-action_id'
    
    create_table :sscstore_buys do |t|
      t.integer :trx_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    add_index :sscstore_buys, %i(trx_id recipient), name: 'sscstore_buys-by-trx_id-recipient'
    
    create_table :steempegged_buys do |t|
      t.integer :trx_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    add_index :steempegged_buys, %i(trx_id recipient), name: 'steempegged_buys-by-trx_id-recipient'
    
    create_table :steempegged_remove_withdrawals do |t|
      t.integer :trx_id, null: false
      t.string :action_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    add_index :steempegged_remove_withdrawals, %i(trx_id recipient), name: 'steempegged_remove_withdrawals-by-trx_id-action_id-recipient'
    
    create_table :steempegged_withdraws do |t|
      t.integer :trx_id, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
    
    create_table :transaction_accounts do |t|
      t.string :account, null: false
      t.integer :trx_id, null: false
    end
    
    add_index :transaction_accounts, %i(account trx_id), unique: true, name: 'transaction_accounts-by-symbol-trx_id'
    
    create_table :transaction_symbols do |t|
      t.string :symbol, null: false
      t.integer :trx_id, null: false
    end
    
    add_index :transaction_symbols, %i(symbol trx_id), unique: true, name: 'transaction_symbols-by-symbol-trx_id'
    
    create_table :checkpoints do |t|
      t.integer :block_num, null: false
      t.string :block_hash, null: false
      t.datetime :block_timestamp, null: false
      t.string :ref_trx_id, null: false
      t.timestamps null: false
    end
  end
end
