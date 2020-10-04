class CreateMarketUnlockTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :market_unlock_tokens do |t|
      t.integer :trx_id, null: false
      t.string :recipient, null: false
      t.string :amount_steemsbd, null: false
      t.timestamps null: false
    end
    
    add_index :market_unlock_tokens, %i(trx_id recipient amount_steemsbd), name: 'market_unlock_tokens-by-trx_id-recipient-amount_steemsbd'
  end
end
