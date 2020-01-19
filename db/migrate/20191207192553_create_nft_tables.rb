class CreateNftTables < ActiveRecord::Migration[6.0]
  def change
    create_table :nft_creates do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :name, null: false
      t.string :url, null: false, default: ''
      t.string :max_supply
      t.text :authorized_issuing_accounts, null: false
      t.timestamps null: false
    end
    
    add_index :nft_creates, %i(trx_id symbol), name: 'nft_creates-by-trx_id-symbol'
    
    create_table :nft_add_properties do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :name, null: false
      t.string :property_type, null: false
      t.boolean :is_read_only, null: false
      t.timestamps null: false
    end
    
    add_index :nft_add_properties, %i(trx_id symbol name property_type), name: 'nft_add_properties-by-trx_id-symbol-name-property_type'
    
    create_table :nft_update_names do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
    
    add_index :nft_update_names, %i(trx_id symbol), name: 'nft_update_names-by-trx_id-symbol'
    
    create_table :nft_update_metadata do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.text :metadata, null: false
      t.timestamps null: false
    end
    
    add_index :nft_update_metadata, %i(trx_id symbol), name: 'nft_update_metadata-by-trx_id-symbol'
    
    create_table :nft_issues do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.string :to, null: false
      t.string :fee_symbol, null: false
      t.text :lock_tokens, null: false
      t.text :properties, null: false
      t.timestamps null: false
    end
    
    add_index :nft_issues, %i(trx_id symbol to fee_symbol), name: 'nft_issues-by-trx_id-symbol-to-fee_symbol'
    
    create_table :nftmarket_enable_markets do |t|
      t.integer :trx_id, null: false
      t.string :symbol, null: false
      t.timestamps null: false
    end
    
    add_index :nft_update_metadata, %i(trx_id symbol), name: 'nftmarket_enable_markets-by-trx_id-symbol'
  end
end
