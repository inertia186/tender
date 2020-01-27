class AddIsErrorToTransaction < ActiveRecord::Migration[6.0]
  INDEX_NAME = 'transactions-by-trx_id-trx_in_block-sender-contract-action-is'
  
  @connection = ActiveRecord::Base.connection
  
  case @connection.instance_values["config"][:adapter]
  when 'sqlite3'
    @connection.execute 'PRAGMA locking_mode = EXCLUSIVE'
    @connection.execute 'PRAGMA synchronous = OFF'
    @connection.execute 'PRAGMA auto_vacuum = NONE'
  end
  
  def up
    add_column :transactions, :is_error, :boolean, null: false, default: '1'
    
    # This will use the old, slow matching pattern to set the new boolean.
    rows = Transaction.where("logs NOT LIKE '%\"errors\":%'").update_all(is_error: false)
    puts "Updated transactions: #{rows}"
    
    add_index :transactions, %i(block_num trx_id trx_in_block sender contract action is_error timestamp), name: INDEX_NAME
  end
  
  def down
    remove_index :transactions, name: INDEX_NAME
    remove_column :transactions, :is_error
  end
end
