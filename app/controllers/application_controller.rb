class ApplicationController < ActionController::Base
  include Pagy::Backend
  
  helper_method :transparent_gif
  helper_method :mainchain, :core_symbol
  helper_method :condenser_api
  helper_method :public_engine_blockchain, :engine_blockchain
  helper_method :public_head_block_num, :head_block_num
  helper_method :replaying?
  helper_method :contract_deploy_block_num
  helper_method :total_tokens_count, :total_nfts_count, :total_contracts_count, :active_witnesses_count
  helper_method :token_metadata, :token_icon
  
  before_action :set_query_only
  after_action :close_agents
private
  def transparent_gif
    'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
  end
  
  def contract_deploy_block_num(contract_name)
    @@contract_deploy_block_num ||= {}
    
    @@contract_deploy_block_num[contract_name] ||= ContractDeploy.where(name: contract_name).joins(:trx).minimum(:block_num) rescue -1
  end
  
  # Nothing should ever be written from any action, so certain PRAGMA
  # assumptions can be made.
  # 
  # See: https://www.sqlite.org/pragma.html#query_only
  def set_query_only
    return if Rails.env.test?
    
    connection = ActiveRecord::Base.connection
    
    case connection.instance_values["config"][:adapter]
    when 'sqlite3'
      connection.execute 'PRAGMA query_only = True'
      connection.execute 'PRAGMA read_uncommitted = True'
      connection.execute 'PRAGMA writable_schema = False'
      connection.execute 'PRAGMA synchronous = OFF'
      connection.execute 'PRAGMA journal_mode = MEMORY'
      connection.execute 'PRAGMA temp_store = MEMORY'
    end
  end
  
  def mainchain
    ENV.fetch('MAINCHAIN', 'hive')
  end
  
  def core_symbol
    case mainchain.to_sym
    when :steem then 'STEEMP'
    when :hive then 'SWAP.HIVE'
    end
  end
  
  def engine_chain_key_prefix
    ENV.fetch('ENGINE_CHAIN_KEY_PREFIX', 'hive_engine')
  end
  
  def mainchain_options
    @mainchain_options ||= {
      # chain: mainchain,
      url: ENV.fetch('MAINCHAIN_NODE_URL', 'https://api.openhive.network'),
      persist: false
    }
    
    if @mainchain_options[:failover_urls].nil?
      if !!ENV['MAINCHAIN_NODE_FAILOVER_URLS']
        failover_urls = ENV['MAINCHAIN_NODE_FAILOVER_URLS'].split(',')
      elsif mainchain == 'hive'
        failover_urls = [
          'https://anyx.io',
          'http://anyx.io',
          'https://api.hivekings.com',
          'https://api.hive.blog',
          'https://api.openhive.network',
          'https://techcoderx.com',
          'https://rpc.esteem.app',
          'https://hived.privex.io',
          'https://api.pharesim.me',
          'https://rpc.ausbit.dev'
        ]
      elsif mainchain == 'steem'
        failover_urls = [
          'https://api.steemit.com/',
          'https://api.justyy.com/'
        ]
      end
      
      @mainchain_options = @mainchain_options.merge(failover_urls: failover_urls)
    end
    
    @mainchain_options
  end
    
  def engine_options
    @engine_options ||= {
      root_url: ENV.fetch('ENGINE_NODE_URL', 'https://api.hive-engine.com/rpc'),
      persist: false
    }
  end
  
  def public_engine_options
    @engine_options ||= {
      root_url: ENV.fetch('PUBLIC_ENGINE_NODE_URL', 'https://api.hive-engine.com/rpc'),
      persist: false
    }
  end
  
  def condenser_api
    @condenser_api ||= Radiator::CondenserApi.new(mainchain_options)
  end
  
  def public_engine_blockchain
    @public_engine_blockchain ||= Radiator::SSC::Blockchain.new(public_engine_options)
  end
  
  def engine_blockchain
    @engine_blockchain ||= Radiator::SSC::Blockchain.new(engine_options)
  end
  
  def engine_contracts
    @engine_contracts ||= Radiator::SSC::Contracts.new(engine_options)
  end
  
  def token_balance(options = {})
    engine_contracts.find_one(
      contract: :tokens,
      table: :balances,
      query: {
        symbol: options[:symbol],
        account: options[:account]
      }
    )
  end
  
  def steem_head_block_num
    condenser_api.get_dynamic_global_properties do |dgpo|
      @datetime = steem_time = Time.parse(dgpo.time + 'Z')
      steem_head_block_num = dgpo.head_block_number
    end
  end
  
  def steem_datetime
    condenser_api.get_dynamic_global_properties do |dgpo|
      steem_time = Time.parse(dgpo.time + 'Z')
    end
  end
  
  def public_head_block_num
    public_engine_blockchain.latest_block_info['blockNumber'] rescue nil || -1
  end
  
  def head_block_num
    @head_block_num ||= Transaction.maximum(:block_num) || -1
  end
  
  def replaying?
    block_num = public_head_block_num
    
    (block_num - Transaction.order(id: :desc).limit(1000).pluck(:block_num).min).abs > 48 ||
    (block_num - head_block_num).abs > 48
  end
  
  def close_agents
    if !!@condenser_api
      Rails.logger.debug { "Closing: #{@condenser_api.inspect}"}
      
      @condenser_api.shutdown
      @condenser_api = nil
    end
    
    if !!@public_engine_blockchain
      Rails.logger.debug { "Closing: #{@public_engine_blockchain.inspect}"}
      
      @public_engine_blockchain.shutdown
      @public_engine_blockchain = nil
    end
    
    if !!@engine_blockchain
      Rails.logger.debug { "Closing: #{@engine_blockchain.inspect}"}
      
      @engine_blockchain.shutdown
      @engine_blockchain = nil
    end
    
    if !!@engine_contracts
      Rails.logger.debug { "Closing: #{@engine_contracts.inspect}"}
      
      @engine_contracts.shutdown
      @engine_contracts = nil
    end
  end
  
  def total_tokens_count
    @total_tokens_count ||= cache ['total-tokens-count', TokensCreate.count], expires_in: 15.minutes do
      TokensCreate.distinct(:symbol).count
    end
  end
  
  def total_nfts_count
    @total_nfts_count ||= cache ['total-nfts-count', NftCreate.count], expires_in: 15.minutes do
      NftCreate.distinct(:symbol).count
    end
  end
  
  def total_contracts_count
    @total_contracts_count ||= cache ['total-contracts-count', ContractDeploy.count, ContractUpdate.count], expires_in: 15.minutes do
      (ContractDeploy.pluck(:name) + ContractUpdate.pluck(:name)).uniq.size
    end
  end
  
  def active_witnesses_count
    @active_witnesses_count ||= cache ['active-witnesses-count', WitnessesRegister.count], expires_in: 15.minutes do
      witnesses = []
      
      WitnessesRegister.joins(:trx).order(block_num: :asc).each do |witness|
        witnesses += [witness.recipient] if witness.enabled?
        witnesses -= [witness.recipient] unless witness.enabled?
        
        witnesses = witnesses.uniq
      end
      
      witnesses.size
    end
  end
  
  def token_metadata(symbol)
    @token_metadata ||= {}
    
    @token_metadata[symbol] ||= TokensUpdateMetadata.where(symbol: symbol).where("metadata LIKE '%\"icon\":%'").last
    @token_metadata[symbol] ||= NftUpdateMetadata.where(symbol: symbol).where("metadata LIKE '%\"icon\":%'").last
  end
  
  def token_icon(symbol, options = {img_class: '', width: 48, height: 48})
    Rails.cache.fetch("icon-#{symbol}-#{options.inspect}", expires_in: 10.minutes) do
      metadata = token_metadata(symbol)
      img_class = options[:img_class] || ''
      width = options[:width] || 48
      height = options[:height] || 48
      icon_html = "<span><img class=\"#{img_class}\" src=\"#{transparent_gif}\" width=\"#{width}\" height=\"#{height}\" /></span>"
      
      if !!metadata
        (JSON[metadata.metadata] rescue {}).each do |k, v|
          next unless k == 'icon'
          next unless v.present?
          
          icon_url = v.sub(/^\(/, '')
          icon_url = URI(icon_url) rescue nil
          
          if !!icon_url
            icon_html = "<span><img class=\"#{img_class}\" src=\"#{icon_url}\" width=\"#{width}\" height=\"#{height}\" /></span>"
            
            break
          end
        end
      else
        if !!(nft_create = NftCreate.where(symbol: symbol).first)
          icon_url = if !!(nft_update_url = NftUpdateUrl.where(symbol: symbol).last)
            nft_update_url.url
          else
            nft_create.url
          end
          
          icon_url = URI("#{icon_url}/favicon.ico") rescue nil
          
          if !!icon_url
            icon_html = "<span><img class=\"#{img_class}\" src=\"#{icon_url}\" width=\"#{width}\" height=\"#{height}\" /></span>"
          end
        end
      end
      
      icon_html.html_safe
    end
  end
end
