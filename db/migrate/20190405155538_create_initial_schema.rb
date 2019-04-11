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
    add_index :transactions, %i(trx_id trx_in_block), unique: true, name: 'transactions-by-trx_id-trx_in_block'
    add_index :transactions, %i(database_hash trx_id trx_in_block), unique: true, name: 'transactions-by-database_hash-trx_id-trx_in_block'
    
    add_index :transactions, %i(block_num trx_id trx_in_block sender contract action timestamp), name: 'transactions-by-trx_id-trx_in_block-sender-contract-action-ti'
    
    create_table :tokens_issues do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.string :quantity, null: false
      t.string :memo, null: false, default: ''
      t.timestamps null: false
    end
    
    create_table :tokens_transfers do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.string :quantity, null: false
      t.string :memo, null: false, default: ''
      t.timestamps null: false
    end
    
    create_table :tokens_creates do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.string :name, null: false
      t.string :url, null: false, default: ''
      t.integer :precision, null: false
      t.integer :max_supply, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_creates, :symbol, unique: true, name: 'tokens_creates-by-symbol'

    create_table :tokens_transfer_ownerships do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.timestamps null: false
    end
    
    create_table :tokens_update_metadata do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.text :metadata, null: false
      t.timestamps null: false
    end
    
    create_table :tokens_update_urls do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.text :url, null: false
      t.timestamps null: false
    end
    
    create_table :market_buys do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.string :price, null: false
      t.timestamps null: false
    end
    
    create_table :market_sells do |t|
      t.string :trx_id, null: false
      t.string :symbol, null: false
      t.string :quantity, null: false
      t.string :price, null: false
      t.timestamps null: false
    end
    
    create_table :market_cancels do |t|
      t.string :trx_id, null: false
      t.string :action_type, null: false
      t.string :action_id, null: false
      t.timestamps null: false
    end
    
    create_table :sscstore_buys do |t|
      t.string :trx_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    create_table :steempegged_buys do |t|
      t.string :trx_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    create_table :steempegged_remove_withdrawals do |t|
      t.string :trx_id, null: false
      t.string :action_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    create_table :steempegged_withdraws do |t|
      t.string :trx_id, null: false
      t.string :quantity, null: false
      t.timestamps null: false
    end
  end
end
