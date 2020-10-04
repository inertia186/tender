class CreateMoreNftTables < ActiveRecord::Migration[6.0]
  def change
    add_column :nft_add_properties, :authorized_editing_accounts, :text
    
    create_table :nft_update_params do |t|
      t.integer :trx_id, null: false
      t.string :nft_creation_fee
      t.string :nft_issuance_fee
      t.string :data_property_creation_fee
      t.string :enable_delegation_fee
      t.timestamps null: false
    end
    
    create_table :nft_update_urls do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :url, null: false
      t.timestamps null: false
    end
    
    add_index :nft_update_urls, %i(trx_id symbol), name: 'nft_update_urls-by-trx_id-symbol'
    
    create_table :nft_add_authorized_issuing_accounts do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :accounts, null: false
      t.timestamps null: false
    end
    
    add_index :nft_add_authorized_issuing_accounts, %i(trx_id symbol), name: 'nft_add_authorized_issuing_accounts-by-trx_id-symbol'
    
    create_table :nft_remove_authorized_issuing_accounts do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :accounts, null: false
      t.timestamps null: false
    end
    
    add_index :nft_remove_authorized_issuing_accounts, %i(trx_id symbol), name: 'nft_remove_authorized_issuing_accounts-by-trx_id-symbol'
    
    create_table :nft_add_authorized_issuing_contracts do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :contracts, null: false
      t.timestamps null: false
    end
    
    add_index :nft_add_authorized_issuing_contracts, %i(trx_id symbol), name: 'nft_add_authorized_issuing_contracts-by-trx_id-symbol'
    
    create_table :nft_remove_authorized_issuing_contracts do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :contracts, null: false
      t.timestamps null: false
    end
    
    add_index :nft_remove_authorized_issuing_contracts, %i(trx_id symbol), name: 'nft_remove_authorized_issuing_contracts-by-trx_id-symbol'
    
    create_table :nft_transfer_ownerships do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.timestamps null: false
    end
    
    add_index :nft_transfer_ownerships, %i(trx_id symbol), name: 'nft_transfer_ownerships-by-trx_id-symbol'
    
    create_table :nft_enable_delegations do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :undelegation_cooldown, null: false
      t.timestamps null: false
    end
    
    add_index :nft_enable_delegations, %i(trx_id symbol), name: 'nft_enable_delegations-by-trx_id-symbol'
    
    create_table :nft_set_property_permissions do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :name, null: false
      t.text :accounts
      t.text :contracts
      t.timestamps null: false
    end
    
    add_index :nft_set_property_permissions, %i(trx_id symbol), name: 'nft_set_property_permissions-by-trx_id-symbol'
    
    create_table :nft_set_group_bys do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :properties, null: false
      t.timestamps null: false
    end
    
    add_index :nft_set_group_bys, %i(trx_id symbol), name: 'nft_set_group_bys-by-trx_id-symbol'
    
    create_table :nft_set_properties do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :fromType
      t.text :nfts
      t.timestamps null: false
    end
    
    add_index :nft_set_properties, %i(trx_id symbol), name: 'nft_set_properties-by-trx_id-symbol'
    
    create_table :nft_burns do |t|
      t.integer :trx_id, null: false
      t.text :nfts
      t.timestamps null: false
    end
    
    create_table :nft_transfers do |t|
      t.integer :trx_id, null: false
      t.string :from
      t.string :from_type
      t.string :to, null: false
      t.string :to_type
      t.text :nfts
      t.string :memo, null: false, default: ''
      t.timestamps null: false
    end
    
    add_index :nft_transfers, %i(trx_id to), name: 'nft_transfers-by-trx_id-to'
    
    create_table :nft_delegates do |t|
      t.integer :trx_id, null: false
      t.string :from
      t.string :from_type
      t.string :to, null: false
      t.string :to_type
      t.text :nfts
      t.timestamps null: false
    end
    
    add_index :nft_delegates, %i(trx_id to), name: 'nft_delegates-by-trx_id-to'
    
    create_table :nft_undelegates do |t|
      t.integer :trx_id, null: false
      t.string :from_type
      t.text :nfts
      t.timestamps null: false
    end
    
    create_table :nft_issue_multiples do |t|
      t.integer :trx_id, null: false
      t.text :instances, null: false
      t.timestamps null: false
    end
    
    create_table :nftmarket_change_prices do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :nfts, null: false
      t.string :price, null: false
      t.timestamps null: false
    end
    
    add_index :nftmarket_change_prices, %i(trx_id symbol), name: 'nftmarket_change_prices-by-trx_id-symbol'
    
    create_table :nftmarket_cancels do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :nfts, null: false
      t.timestamps null: false
    end
    
    add_index :nftmarket_cancels, %i(trx_id symbol), name: 'nftmarket_cancels-by-trx_id-symbol'
    
    create_table :nftmarket_buys do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :nfts, null: false
      t.string :market_account, null: false
      t.timestamps null: false
    end
    
    add_index :nftmarket_buys, %i(trx_id symbol), name: 'nftmarket_buys-by-trx_id-symbol'
    
    create_table :nftmarket_sells do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :nfts, null: false
      t.string :price, null: false
      t.integer :fee, null: false
      t.timestamps null: false
    end
    
    add_index :nftmarket_sells, %i(trx_id symbol), name: 'nftmarket_sells-by-trx_id-symbol'
  end
end
