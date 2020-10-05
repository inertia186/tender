namespace :tender do
  desc 'Display the current environment of rake.'
  task :current_environment do
    puts "You are running rake task in #{Rails.env} environment"
  end
  
  namespace :docker do
    desc 'Build a new version of the tender docker image.'
    task :build do
      exec 'docker build -t inertia/tender:latest .'
    end
    
    desc 'Run the latest version of the tender docker image.'
    task :run do
      exec 'docker run -it --name tender -p 6379:6379 -p 5000:5000 -p 3000:3000 inertia/tender:latest'
    end
    
    # desc 'Publish the current version of the tender docker image.'
    # task :push do
    #   exec 'docker push inertia/tender:latest'
    # end
  end
  
  desc 'Current header data for latest blocks.log'
  task :block_log_headers do
    exec 'curl -I "https://api.hive-engine.com/blocks.log"'
  end
  
  desc 'Dump sidechain transactions from Meeseeker.'
  task :trx_dump, [:trx_id] => :environment do |t, args|
    trx_id = args[:trx_id]
    block_num = trx_id.to_i unless trx_id =~ /\D+/
    block = nil
    engine_options ||= {
      root_url: ENV.fetch('ENGINE_NODE_URL', 'https://api.hive-engine.com/rpc'),
      persist: false
    }
    
    engine_blockchain = Radiator::SSC::Blockchain.new(engine_options)
    trxs = if !!block_num
      block = engine_blockchain.block_info(block_num.to_i)
      
      block.transactions + block.virtualTransactions
    else
      trx = engine_blockchain.transaction_info(trx_id)
      block_num = trx['blockNumber']
      
      [trx]
    end
    
    block ||= engine_blockchain.block_info(block_num)
    timestamp = block['timestamp'].sub('T', ' ')
    
    trxs.each do |trx|
      trx_id, trx_in_block = if trx['transactionId'] == 0
        [Transaction::VIRTUAL_TRX_ID, 0]
      else
        trx['transactionId'].split('-')
      end
      
      result = {
        'block_num' => block_num,
        'ref_steem_block_num' => trx['refHiveBlockNumber'],
        'trx_id' => trx_id,
        'trx_in_block' => trx_in_block.to_i,
        'sender' => trx['sender'],
        'contract' => trx['contract'],
        'action' => trx['action'],
        'payload' => trx['payload'],
        'logs' => trx['logs'],
        'executed_code_hash' => trx['executedCodeHash'],
        'hash' => trx['hash'],
        'database_hash' => trx['databaseHash'],
        'timestamp' => timestamp,
        'created_at' => timestamp,
        'updated_at' => timestamp,
      }
      
      puts result.to_yaml
    end
  end
  
  desc 'Ingest sidechain transactions from Meeseeker.'
  task :trx_ingest, [:drop_redis_keys, :max_transactions, :turbo] => :environment do |t, args|
    start = Time.now
    drop_redis_keys = (args[:drop_redis_keys] || 'true') == 'true'
    max_transactions = (args[:max_transactions] || '-1').to_i
    turbo = (args[:turbo] || 'false') == 'true'
    connection = ActiveRecord::Base.connection
    keys = []
    
    if !!turbo
      abort 'Setting turbo requires setting valid max_transactions.' if max_transactions == -1
      
      case connection.instance_values["config"][:adapter]
      when 'sqlite3'
        connection.execute 'PRAGMA synchronous = OFF'
      else
        puts 'Turbo not suppored by current adapter.'
      end
    end
    
    ActiveRecord::Base.transaction do
      if !!turbo
        case connection.instance_values["config"][:adapter]
        when 'sqlite3'
          puts 'Turbo enabled.'
          
          connection.execute 'PRAGMA cache_size = 10000'
          connection.execute 'PRAGMA journal_mode = MEMORY'
          connection.execute 'PRAGMA temp_store = MEMORY'
        end
      end
      
      Transaction.meeseeker_ingest(max_transactions) do |trx, key|
        puts "INGESTED: #{key}"
        keys << key if !!drop_redis_keys
      end
      
      processed = keys.size
      elapsed = Time.now - start
      processed_per_second = elapsed == 0.0 ? 0.0 : processed / elapsed
      puts 'Finished in: %.3f seconds; Total Transactions: %d (processed %.3f transactions per second)' % [elapsed, Transaction.count, processed_per_second]
      puts 'Committing ...'
    end
    
    if keys.any?
      ctx = Redis.new(url: ENV.fetch('MEESEEKER_REDIS_URL', 'redis://127.0.0.1:6379/0'))
      puts "Dropped redis keys: #{ctx.del(keys)}"
    end
    
    puts 'Done!'
  end
  
  desc 'Ingest sidechain orphaned transactions.'
  task :orphan_trx_ingest, [:start_block_num, :max_transactions, :include_virtual_trx, :turbo] => :environment do |t, args|
    engine_chain_key_prefix = ENV.fetch('ENGINE_CHAIN_KEY_PREFIX', 'hive_engine')
    start = Time.now
    start_block_num = (args[:after_block_num] || '0').to_i - 1
    max_transactions = args[:max_transactions]
    include_virtual_trx = (args[:include_virtual_trx] || 'true') == 'true'
    turbo = (args[:turbo] || 'false') == 'true'
    connection = ActiveRecord::Base.connection
    keys = []
    
    ActiveRecord::Base.transaction do
      if !!turbo
        case connection.instance_values["config"][:adapter]
        when 'sqlite3'
          puts 'Turbo enabled.'
          
          connection.execute 'PRAGMA cache_size = 10000'
          connection.execute 'PRAGMA journal_mode = MEMORY'
          connection.execute 'PRAGMA temp_store = MEMORY'
        end
      end
      
      orphaned_transactions = Transaction.where('block_num > ?', start_block_num).
        where(is_error: false).
        where.not(id: TransactionAccount.select(:trx_id))
      
      if !!max_transactions
        orphaned_transactions = orphaned_transactions.limit(max_transactions.to_i)
      end
      
      unless !!include_virtual_trx
        orphaned_transactions = orphaned_transactions.where.not(trx_id: Transaction::VIRTUAL_TRX_ID)
      end

      orphaned_transactions.find_each do |trx|
        begin
          action = trx.send(:parse_contract)
          
          if action.kind_of?(ContractAction) && action.persisted?
            key = "#{engine_chain_key_prefix}:#{action.trx.block_num}:#{action.trx.trx_id}:#{action.trx.trx_in_block}:#{action.trx.contract}:#{action.trx.action}"
            
            puts "INGESTED: #{key}"
            keys << key
          end
        rescue => e
          puts "Skipped #{trx.trx_id} ... (#{e.inspect})"
        end
      end
      
      processed = keys.size
      elapsed = Time.now - start
      processed_per_second = elapsed == 0.0 ? 0.0 : processed / elapsed
      puts 'Finished in: %.3f seconds; Total Transactions: %d (processed %.3f transactions per second)' % [elapsed, Transaction.count, processed_per_second]
      puts 'Committing ...'
    end
    
    abort("No orphaned transactions.") if keys.size == 0
  end
  
  namespace :trx_ingest do
    desc 'Log filtered for trx_ingest messages.'
    task :log do
      exec "cat log/#{Rails.env}.log | grep 'Already ingested:\\|Unable to save \\|Did not persist: '"
    end
  end
  
  desc 'Verify Engine transactions by contract and action.'
  task :trx_verify, [:start_block_num, :contract, :action] => :environment do |t, args|
    engine_chain_key_prefix = ENV.fetch('ENGINE_CHAIN_KEY_PREFIX', 'hive_engine')
    start_block_num = (args[:after_block_num] || '0').to_i - 1
    contract_name = args[:contract]
    action_name = args[:action]
    transactions = Transaction.where('block_num > ?', start_block_num).
      where(is_error: false)
      
    transactions = transactions.where(contract: contract_name) if !!contract_name
    transactions = transactions.where(action: action_name) if !!action_name
    
    transactions.find_each do |trx|
      block_num = trx.block_num
      key = "#{engine_chain_key_prefix}:#{block_num}:#{trx.trx_id}:#{trx.trx_in_block}:#{trx.contract}:#{trx.action}"
      contract_name = trx.contract
      action_name = trx.action
      
      next if contract_name == 'null' && action_name == 'null'
      
      relation_name = "#{contract_name}_#{action_name.underscore.pluralize}"
      
      relation_name = case relation_name
      when 'nft_set_group_bies' then 'nft_set_group_bys'
      else; relation_name
      end
      
      unless trx.respond_to? relation_name
        puts "Unknown action '#{relation_name}' for #{key}"
        
        next
      end
      
      begin
        count = trx.send(relation_name).count
        
        if count == 0
          puts "Unable to find action '#{relation_name}' for #{key}"
        elsif count > 1
          puts "Found duplicate actions '#{relation_name}' for #{key}"
        end
      rescue => e
        puts "Unable to find action '#{relation_name}' for #{key} (#{e})"
      end
      
      puts "√ #{key}" if block_num % 1000 == 0
    end
  end
  
  desc 'Reindex Engine transaction by contract.'
  task :trx_reindex_contract, [:contract, :turbo] => :environment do |t, args|
    engine_chain_key_prefix = ENV.fetch('ENGINE_CHAIN_KEY_PREFIX', 'hive_engine')
    contract_name = args[:contract]
    turbo = (args[:turbo] || 'false') == 'true'
    found_transactions = false
    
    abort "Contract required." unless !!contract_name
    
    transactions = Transaction.where(contract: contract_name)
    
    transactions.distinct.pluck(:action).each do |action_name|
      relation_name = "#{contract_name}_#{action_name.underscore.pluralize}"
      
      relation_name = case relation_name
      when 'nft_set_group_bies' then 'nft_set_group_bys'
      else; relation_name
      end
      
      begin
        count = Transaction.with_logs_errors(false).where(contract: contract_name, action: action_name).count
        class_name = "#{contract_name.upcase_first}#{action_name.upcase_first}"
        klass = begin
          Object.const_get(class_name)
        rescue NameError
          puts "Unsupported action: #{contract_name}.#{action_name} (no class defined for: #{class_name})"
          
          next
        end
        existing_count = klass.count
        
        puts "Reindexing #{count} #{relation_name} (#{existing_count} exist) ..."
        
        Rake::Task['tender:trx_reindex'].invoke(contract_name, action_name, turbo.to_s)
      ensure
        Rake::Task['tender:trx_reindex'].reenable
      end
    end
  end
  
  desc 'Reindex Engine transactions by contract and action.'
  task :trx_reindex, [:contract, :action, :turbo] => :environment do |t, args|
    engine_chain_key_prefix = ENV.fetch('ENGINE_CHAIN_KEY_PREFIX', 'hive_engine')
    contract_name = args[:contract]
    action_name = args[:action]
    turbo = (args[:turbo] || 'false') == 'true'
    found_transactions = false
    
    abort "Contract and action required." unless !!contract_name && !!action_name

    relation_name = "#{contract_name}_#{action_name.underscore.pluralize}"
    
    relation_name = case relation_name
    when 'nft_set_group_bies' then 'nft_set_group_bys'
    else; relation_name
    end

    Transaction.new.send(relation_name) # just testing if the relation exists
    
    class_name = "#{contract_name.upcase_first}#{action_name.upcase_first}"
    klass = begin
      Object.const_get(class_name)
    rescue NameError
      puts "Unsupported action: #{contract_name}.#{action_name} (no class defined for: #{class_name})"
      
      next
    end
    
    transactions = Transaction.where(contract: contract_name, action: action_name)
    
    if !!turbo
      connection = ActiveRecord::Base.connection
      
      case connection.instance_values["config"][:adapter]
      when 'sqlite3'
        puts 'Turbo enabled.'
        
        connection.execute 'PRAGMA cache_size = 10000'
        connection.execute 'PRAGMA journal_mode = MEMORY'
        connection.execute 'PRAGMA temp_store = MEMORY'
      end
    end
    
    ActiveRecord::Base.transaction do
      begin
        klass.destroy_all
        TransactionAccount.where(trx_id: transactions).destroy_all
        TransactionSymbol.where(trx_id: transactions).destroy_all

        transactions.where.not(id: TransactionAccount.select(:trx_id)).find_each do |trx|
          action = trx.send(:parse_contract)
          
          if action.kind_of?(ContractAction) && action.persisted?
            found_transactions = true
            
            puts "REINDEXED: #{engine_chain_key_prefix}:#{action.trx.block_num}:#{action.trx.trx_id}:#{action.trx.trx_in_block}:#{action.trx.contract}:#{action.trx.action}"
          else
            puts "Skipped #{trx.trx_id} ... (#{trx.errors.inspect})"
          end
        end
      rescue => e
        puts "Skipped #{relation_name} ... (#{e.inspect})"
      end
      
      puts 'Committing ...' if found_transactions
    end
    
    abort "Nothing to reindex." unless found_transactions
  end
  
  desc 'Verifies there are no block gaps or duplicate transactions on the sidechain.'
  task verify_sidechain: :environment do
    block_agent = Radiator::SSC::Blockchain.new(root_url: ENV.fetch('ENGINE_NODE_URL'), persist: false)
    checkpoints = Checkpoint.all
    verified_checkpoints = 0
    public_engine_node_url = ENV.fetch('PUBLIC_ENGINE_NODE_URL', 'https://api.hive-engine.com/rpc')
    public_block_agent = Radiator::SSC::Blockchain.new(root_url: public_engine_node_url, persist: false)
    
    checkpoints.find_each do |checkpoint|
      block = block_agent.block_info(checkpoint.block_num)
      problem = false
      
      if checkpoint.block_hash != block['hash']
        puts("Expect block_hash: #{checkpoint.block_hash} but got: #{block['hash']}")
        puts("Problem detected at block_num: #{checkpoint.block_num}")
        problem = true
      end
      
      actual_trx_id = if block.transactions.any?
        block.transactions.first.transactionId.to_s.split('-').first
      else
        block.virtualTransactions.first.transactionId.to_s.split('-').first
      end
      
      if checkpoint.ref_trx_id != actual_trx_id
        puts("Expect block_hash: #{checkpoint.ref_trx_id} but got: #{actual_trx_id}")
        puts("Problem detected at block_num: #{checkpoint.block_num}")
        problem = true
      end
      
      unless !!problem
        verified_checkpoints += 1
        puts "Checkpoint verified at block_num: #{checkpoint.block_num}"
      end
    end
    
    puts "Checkpoints verified: #{verified_checkpoints} of #{checkpoints.count}"
    
    block_num = (Checkpoint.maximum(:block_num) || -1) + 1
    previous_hash = nil
    trx_ids = {}
    
    while !!(block = block_agent.block_info(block_num))
      block_num % 1000 == 0 and print '.'
      
      if block_num % Checkpoint::CHECKPOINT_LENGTH == 0
        trx = if block.transactions.any?
          block.transactions.first
        else
          block.virtualTransactions.first
        end
        
        if trx.nil?
          puts "\nNo transactions in block."
          abort("Problem detected at block_num: #{block_num}")
        end
        
        public_block = public_block_agent.block_info(block_num)
        
        if block['hash'] != public_block['hash']
          puts("\nProblem comparing #{ENV['ENGINE_NODE_URL']} and #{public_engine_node_url}")
          puts("Expect block_hash: #{block['hash']} but got: #{public_block['hash']}")
          abort("Problem detected at block_num: #{block_num}")
        end
        
        Checkpoint.create!(
          block_num: block_num,
          block_hash: block['hash'],
          block_timestamp: block['timestamp'],
          ref_trx_id: trx.transactionId.to_s.split('-').first
        )
      end
      
      if !!previous_hash && previous_hash != block.previousHash
        puts "\nprevious_hash:      #{previous_hash}"
        puts "block.previousHash: #{block.previousHash}"
        abort("Problem detected at block_num: #{block_num}")
      end
      
      block.transactions.each do |trx|
        (trx_id = trx.transactionId) == 0 and next
        trx_id, idx = trx_id.split('-')
        
        if trx_ids.keys.include?(trx_id) && trx_ids[trx_id] != block_num
          puts "\nFound duplicate transaction id (#{trx_id}) already seen in block: #{trx_ids[trx_id]}"
          abort("Problem detected at block_num: #{block_num}")
        end
        
        trx_ids[trx_id] = block_num
      end
      
      block_num += 1
      previous_hash = block['hash']
    end
    
    puts "\nVerify complete, ending with block: #{block_num}"
  end
  
  desc 'Rollback to latest checkpoint.'
  task rollback: :environment do
    block_num = Checkpoint.maximum(:block_num) || 0
    trxs = nil
    
    until (trxs = Transaction.where("block_num > ?", block_num)).exists?
      block_num -= Checkpoint::CHECKPOINT_LENGTH
    end
    
    trxs = if ENV['PRETEND'].nil? || ENV['pretend'] == 'true'
      puts "Rolling back to block_num: #{block_num} (pretend mode)"
      trxs
    elsif ENV['PRETEND'] == 'false'
      puts "Rolling back to block_num: #{block_num}"
      trxs.destroy_all
    end
    
    puts "Done.  Transactions destroyed: #{trxs.count}"
  end
  
  task find_typo_accounts: :environment do
    valid_account_names = Transaction.distinct.pluck(:sender)
    account_names = TokensTransferOwnership.distinct.pluck(:to)
    account_names = TokensTransfer.distinct.pluck(:to)
    account_names += TokensIssue.distinct.pluck(:to)
    account_names = account_names.map(&:downcase).uniq - valid_account_names
    typo_account_names = {}
    engine_contracts = Radiator::SSC::Contracts.new(root_url: ENV.fetch('ENGINE_NODE_URL', 'https://api.hive-engine.com/rpc'))

    puts 'All accounts: %d ' % account_names.size
    
    account_names = account_names.select do |name|
      !name.include?(' ') && !name.include?('_') && !(name =~ /\.$/) &&
        !(name =~ /^@/)
    end
    
    puts 'Valid accounts: %d ' % account_names.size
    
    api = Radiator::CondenserApi.new
    
    account_names.each_slice(1000) do |slice|
      api.get_accounts(slice) do |accounts|
        slice -= accounts.map{|a| a.name}
        print '.'
      end
      
      slice.each do |name|
        typo_account_names[name] = nil
      end
    end
    
    puts "\nTypo accounts: %d" % typo_account_names.size
    
    typo_account_names.each do |k, v|
      typo_account_names[k] = engine_contracts.find(
        contract: :tokens,
        table: :balances,
        query: {
          account: k
        }
      ).map{|b| [b['symbol'], b['balance']]}.to_h
    end
    
    puts JSON.pretty_generate typo_account_names
  end
end
