class CreateInflationTables < ActiveRecord::Migration[6.0]
  def change
    create_table :inflation_issue_new_tokens do |t|
      t.integer :trx_id, null: false
      t.timestamps null: false
    end
    
    add_index :inflation_issue_new_tokens, %i(trx_id), name: 'inflation_issue_new_tokens-by-trx_id'
  end
end
