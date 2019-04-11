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
  task trx_ingest: :environment do
    start = Time.now
    processed = 0
    Transaction.meeseeker_ingest do |trx, key|
      puts "INGESTED: #{key}"
      
      processed += 1
    end
    elapsed = Time.now - start
    processed_per_second = elapsed == 0.0 ? 0.0 : processed / elapsed
    puts 'Finished in: %.3f seconds; Total Transactions: %d (processed %.3f transactions per second)' % [elapsed, Transaction.count, processed_per_second]
  end
  
  desc 'Verifies there are no block gaps or duplicate transactions on the sidechain.'
  task :verify_sidechain do
    block_agent = Radiator::SSC::Blockchain.new(root_url: ENV.fetch('STEEM_ENGINE_NODE_URL'))
    block_num = 0
    previous_hash = nil
    trx_ids = {}
    
    while !!(block = block_agent.block_info(block_num))
      block_num % 1000 == 0 and print '.'
      
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
end
