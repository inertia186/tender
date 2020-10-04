class CreateWitnessesTables < ActiveRecord::Migration[6.0]
  def change
    create_table :witnesses_registers do |t|
      t.integer :trx_id, null: false
      t.string :ip, null: false
      t.integer :rpc_port, null: false
      t.integer :p2p_port, null: false
      t.string :signing_key, null: false
      t.boolean :enabled, null: false
      t.string :recipient, null: false, default: ''
      t.string :amount_steemsbd, null: false, default: ''
      t.timestamps null: false
    end
    
    add_index :witnesses_registers, %i(trx_id ip signing_key recipient), name: 'witnesses_registers-by-trx_id-ip-signing_key-recipient'
    
    create_table :witnesses_update_witness_approvals do |t|
      t.integer :trx_id, null: false
      t.string :account, null: false
      t.timestamps null: false
    end
    
    add_index :witnesses_update_witness_approvals, %i(trx_id, account), name: 'witnesses_update_witness_approvals-by-trx_id-account'
    
    create_table :witnesses_propose_rounds do |t|
      t.integer :trx_id, null: false
      t.integer :round, null: false
      t.string :round_hash, null: false
      t.text :signatures, null: false
      t.timestamps null: false
    end
    
    add_index :witnesses_propose_rounds, %i(trx_id round), name: 'witnesses_propose_rounds-by-trx_id-round'
    
    create_table :witnesses_approves do |t|
      t.integer :trx_id, null: false
      t.string :witness, null: false
      t.timestamps null: false
    end
    
    add_index :witnesses_approves, %i(trx_id witness), name: 'witnesses_approves-by-trx_id-witness'

    create_table :witnesses_disapproves do |t|
      t.integer :trx_id, null: false
      t.string :witness, null: false
      t.timestamps null: false
    end
    
    add_index :witnesses_disapproves, %i(trx_id witness), name: 'witnesses_disapproves-by-trx_id-witness'
    
    create_table :witnesses_schedule_witnesses do |t|
      t.integer :trx_id, null: false
      t.timestamps null: false
    end
    
    add_index :witnesses_schedule_witnesses, %i(trx_id), name: 'witnesses_schedule_witnesses-by-trx_id'
  end
end
