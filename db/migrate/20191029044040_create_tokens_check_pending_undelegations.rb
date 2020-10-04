class CreateTokensCheckPendingUndelegations < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens_check_pending_undelegations do |t|
      t.integer :trx_id, null: false
      t.timestamps null: false
    end
    
    add_index :tokens_check_pending_undelegations, %i(trx_id), name: 'tokens_check_pending_undelegations-by-trx_id'
  end
end
