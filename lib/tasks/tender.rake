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
    exec 'curl -I "https://api.steem-engine.com/blocks.log"'
  end
  
  desc 'Ingest Steem Engine transactions from Meeseeker.'
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
  
  desc 'Ingest Steem Engine orphaned transactions.'
  task :orphan_trx_ingest, [:max_transactions, :include_virtual_trx] => :environment do |t, args|
    max_transactions = args[:max_transactions]
    include_virtual_trx = (args[:include_virtual_trx] || 'true') == 'true'
    orphaned_transactions = Transaction.with_logs_errors(false).
      where.not(id: TransactionAccount.select(:trx_id))
    
    if !!max_transactions
      orphaned_transactions = orphaned_transactions.limit(max_transactions.to_i)
    end
    
    unless !!include_virtual_trx
      orphaned_transactions = orphaned_transactions.where.not(trx_id: Transaction::VIRTUAL_TRX_ID)
    end
    
    abort("No orphaned transactions.") if orphaned_transactions.none?
    
    orphaned_transactions.find_each do |trx|
      begin
        trx.send(:parse_contract)
      rescue => e
        puts "Skipped #{trx.trx_id} ... (#{e.inspect})"
      end
    end
  end
  
  namespace :trx_ingest do
    desc 'Log filtered for trx_ingest messages.'
    task :log do
      exec "cat log/#{Rails.env}.log | grep 'Already ingested:\\|Unable to save \\|Did not persist: '"
    end
  end
  
  desc 'Verifies there are no block gaps or duplicate transactions on the sidechain.'
  task verify_sidechain: :environment do
    block_agent = Radiator::SSC::Blockchain.new(root_url: ENV.fetch('STEEM_ENGINE_NODE_URL'), persist: false)
    checkpoints = Checkpoint.all
    verified_checkpoints = 0
    public_steem_engine_node_url = ENV.fetch('PUBLIC_STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc', persist: false)
    public_block_agent = Radiator::SSC::Blockchain.new(root_url: public_steem_engine_node_url)
    
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
      
      if true#block_num % Checkpoint::CHECKPOINT_LENGTH == 0
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
          puts("\nProblem comparing #{ENV['STEEM_ENGINE_NODE_URL']} and #{public_steem_engine_node_url}")
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
  
  task find_typo_accounts: :environment do
    valid_account_names = Transaction.distinct.pluck(:sender)
    account_names = TokensTransferOwnership.distinct.pluck(:to)
    account_names = TokensTransfer.distinct.pluck(:to)
    account_names += TokensIssue.distinct.pluck(:to)
    account_names = account_names.map(&:downcase).uniq - valid_account_names
    typo_account_names = {}
    steem_engine_contracts = Radiator::SSC::Contracts.new(root_url: ENV.fetch('STEEM_ENGINE_NODE_URL', 'https://api.steem-engine.com/rpc'))

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
      typo_account_names[k] = steem_engine_contracts.find(
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
