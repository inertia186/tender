require "test_helper"
require "mock_redis"

class TransactionTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @contracts = {
      contract: %i(deploy update),
      market: %i(buy cancel sell unlock_tokens),
      sscstore: %i(buy),
      steempegged: %i(buy remove_withdrawal withdraw),
      tokens: %i(cancel_unstake check_pending_unstakes create delegate
        enable_delegation enable_staking issue stake transfer_ownership
        transfer_to_contract transfer undelegate unstake update_metadata
        update_param update_precision update_url check_pending_undelegations)
    }
    
    @skipped_contracts = {
      tokens: %i(update_param)
    }
  end
  
  def test_with_logs_errors
    assert Transaction.with_logs_errors.any?, 'expect log errors'
    assert Transaction.with_logs_errors(false).none?, "expect no log errors, got: #{Transaction.with_logs_errors(false).count}"
  end
  
  def test_contract
    assert Transaction.contract(:tokens).any?, 'expect tokens contract transactions'
    assert Transaction.contract(:tokens, invert: true).any?, 'expect non-tokens contract transactions'
    assert Transaction.contract([:tokens, :market]).any?, 'expect compound contract transactions'
    assert Transaction.contract([:tokens, :market], invert: true).any?, 'expect non-compound contract transactions'
  end
  
  def test_virtual
    assert (virtual_trxs = Transaction.virtual).any?, 'expect virtual transactions'
    assert Transaction.virtual(false).any?, 'expect non-virtual transactions'
    assert virtual_trxs.map(&:virtual?).uniq == [true], 'expect virtual transactions to be virtual'
  end
  
  def test_relations
    transaction = Transaction.new
    
    @contracts.each do |contract, actions|
      actions.each do |action|
        relation = "#{contract}_#{action.to_s.pluralize}"
        
        assert transaction.send(relation).empty?, "expect empty relation: #{relation}"
      end
    end
  end
  
  def test_parse_contracts
    Transaction.find_each do |trx|
      trx.send :parse_error
      trx.send :parse_contract
    end
    
    @contracts.each do |contract, actions|
      actions.each do |action|
        action_name = action.to_s.camelize(:lower)
        trxs = Transaction.where(contract: contract, action: action_name)
        relation = "#{contract}_#{action.to_s.pluralize}"
        
        if !!@skipped_contracts[contract] && !!@skipped_contracts[contract].include?(action)
          # These do not have any examples to test yet.  If we end up finding
          # one, we need to remove it from the skipped contracts.
          
          refute trxs.any?, "did not expect relation for contract: #{contract}, action: #{action_name}"
          refute !!trxs.first && trxs.first.send(relation).present?, "did not expect relation: #{relation}"
        else
          refute trxs.none?, "did not expect empty relation for contract: #{contract}, action: #{action_name}"
          refute trxs.first.send(relation).empty?, "did not expect empty relation: #{relation}"
        end
      end
    end
  end
  
  def test_meeseeker_ingest
    ctx = MockRedis.new
    
    # NftTransfer
    ctx.set('hive_engine:2277756:4267874ac09736ec8ba0db9152caf62ecfd5fd4b:0:nft:transfer', "{\"refHiveBlockNumber\":47480823,\"transactionId\":\"4267874ac09736ec8ba0db9152caf62ecfd5fd4b\",\"sender\":\"cardseller\",\"contract\":\"nft\",\"action\":\"transfer\",\"payload\":\"{\\\"nfts\\\":[{\\\"symbol\\\":\\\"CITY\\\",\\\"ids\\\":[\\\"6133\\\"]}],\\\"to\\\":\\\"nftmart.cards\\\",\\\"memo\\\":\\\"sellIndividual 0.45 HIVE\\\",\\\"isSignedWithActiveKey\\\":true}\",\"executedCodeHash\":\"a9fcb0e0d0c8e3f97888f8f95b743deb5f20574152118b23be0a8dea3077108b\",\"hash\":\"01dea51f7368ec693769ae5feb791c5f9a9c97a8b36f3eaf9eb3364a6df67f33\",\"databaseHash\":\"119d06f07886c6434ba119d22348d2b926a709e6edc731ff644d9701c6d2c1ae\",\"logs\":\"{\\\"events\\\":[{\\\"contract\\\":\\\"nft\\\",\\\"event\\\":\\\"transfer\\\",\\\"data\\\":{\\\"from\\\":\\\"cardseller\\\",\\\"fromType\\\":\\\"u\\\",\\\"to\\\":\\\"nftmart.cards\\\",\\\"toType\\\":\\\"u\\\",\\\"symbol\\\":\\\"CITY\\\",\\\"id\\\":\\\"6133\\\"}}]}\",\"timestamp\":\"2020-10-03T18:31:18\"}")
    
    # NftTransfer (invalid) ("to" missing)
    ctx.set('hive_engine:2277756:4267874ac09736ec8ba0db9152caf62ecfd5fd4b:1:nft:transfer', "{\"refHiveBlockNumber\":47480823,\"transactionId\":\"4267874ac09736ec8ba0db9152caf62ecfd5fd4b\",\"sender\":\"cardseller\",\"contract\":\"nft\",\"action\":\"transfer\",\"payload\":\"{\\\"nfts\\\":[{\\\"symbol\\\":\\\"CITY\\\",\\\"ids\\\":[\\\"6133\\\"]}],\\\"memo\\\":\\\"sellIndividual 0.45 HIVE\\\",\\\"isSignedWithActiveKey\\\":true}\",\"executedCodeHash\":\"a9fcb0e0d0c8e3f97888f8f95b743deb5f20574152118b23be0a8dea3077108b\",\"hash\":\"01dea51f7368ec693769ae5feb791c5f9a9c97a8b36f3eaf9eb3364a6df67f33\",\"databaseHash\":\"119d06f07886c6434ba119d22348d2b926a709e6edc731ff644d9701c6d2c1ae\",\"logs\":\"{\\\"events\\\":[{\\\"contract\\\":\\\"nft\\\",\\\"event\\\":\\\"transfer\\\",\\\"data\\\":{\\\"from\\\":\\\"cardseller\\\",\\\"fromType\\\":\\\"u\\\",\\\"to\\\":\\\"nftmart.cards\\\",\\\"toType\\\":\\\"u\\\",\\\"symbol\\\":\\\"CITY\\\",\\\"id\\\":\\\"6133\\\"}}]}\",\"timestamp\":\"2020-10-03T18:31:18\"}")
    
    # NftTransfer (invalid) ("action" missing)
    ctx.set('hive_engine:2277756:4267874ac09736ec8ba0db9152caf62ecfd5fd4b:2:nft:transfer', "{\"refHiveBlockNumber\":47480823,\"transactionId\":\"4267874ac09736ec8ba0db9152caf62ecfd5fd4b\",\"sender\":\"cardseller\",\"contract\":\"nft\",\"payload\":\"{\\\"nfts\\\":[{\\\"symbol\\\":\\\"CITY\\\",\\\"ids\\\":[\\\"6133\\\"]}],\\\"memo\\\":\\\"sellIndividual 0.45 HIVE\\\",\\\"isSignedWithActiveKey\\\":true}\",\"executedCodeHash\":\"a9fcb0e0d0c8e3f97888f8f95b743deb5f20574152118b23be0a8dea3077108b\",\"hash\":\"01dea51f7368ec693769ae5feb791c5f9a9c97a8b36f3eaf9eb3364a6df67f33\",\"databaseHash\":\"119d06f07886c6434ba119d22348d2b926a709e6edc731ff644d9701c6d2c1ae\",\"logs\":\"{\\\"events\\\":[{\\\"contract\\\":\\\"nft\\\",\\\"event\\\":\\\"transfer\\\",\\\"data\\\":{\\\"from\\\":\\\"cardseller\\\",\\\"fromType\\\":\\\"u\\\",\\\"to\\\":\\\"nftmart.cards\\\",\\\"toType\\\":\\\"u\\\",\\\"symbol\\\":\\\"CITY\\\",\\\"id\\\":\\\"6133\\\"}}]}\",\"timestamp\":\"2020-10-03T18:31:18\"}")
    
    # checkPendingUnstakes
    ctx.set('hive_engine:2277780:0000000000000000000000000000000000000000:0:tokens:checkPendingUnstakes', "{\"refHiveBlockNumber\":47480855,\"transactionId\":\"0000000000000000000000000000000000000000-0\",\"sender\":\"null\",\"contract\":\"tokens\",\"action\":\"checkPendingUnstakes\",\"payload\":\"\",\"executedCodeHash\":\"b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9\",\"hash\":\"87e63699cb946eeb47eb08c1051fbbb45323471f7f38d5b4f7638e8ce024047b\",\"databaseHash\":\"ca69c8204ec6bc0a09f3456c8412d881dc8db149841cbdc68fa206304f9f7312\",\"logs\":\"{\\\"events\\\":[{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"unstake\\\",\\\"data\\\":{\\\"account\\\":\\\"kidsisters\\\",\\\"symbol\\\":\\\"ARCHON\\\",\\\"quantity\\\":\\\"0.00039915\\\"}}]}\",\"timestamp\":\"2020-10-03T18:32:54\"}")
    
    # BotcontrollerTick (ignored)
    ctx.set('hive_engine:2277775:0000000000000000000000000000000000000000:0:botcontroller:tick', "{\"refHiveBlockNumber\":47480849,\"transactionId\":\"0000000000000000000000000000000000000000-3\",\"sender\":\"null\",\"contract\":\"botcontroller\",\"action\":\"tick\",\"payload\":\"\",\"executedCodeHash\":\"1435880940b66aea001a85a5f06c0f2fe4e207cc485115950699be2e73dbca4ba51a80b5211fe781b6f3b7017078eff891b3af4ef31a57cca37050895865331f558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9558bdb4dcb9011f2d736ff5e0ea9eee0d95deb118c7ab26bc9e65e6a2e78e528b39ab06d0122894d01c2c6a1b67d85c8c342178177d1e54bda6538b99d49ece9\",\"hash\":\"88d42f78b8f78a71d46c49b3e34e54ba799e2d0f00ff78882d9553aeee1fb1c2\",\"databaseHash\":\"104522457f9bf2d3d9b50fa82153a1e179451e854596b32cbaafde2807f9ca96\",\"logs\":\"{\\\"events\\\":[{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"crystalking\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"20000.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"crystalking\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"20000.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"crystalking\\\",\\\"symbol\\\":\\\"SWAP.STEEM\\\",\\\"quantity\\\":\\\"100.00000000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"crystalking\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"SWAP.STEEM\\\",\\\"quantity\\\":\\\"100.00000000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"eonwarped\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"24978.156\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"eonwarped\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"25000.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"sm-usd\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"0.001\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"eonwarped\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"0.00000508\\\"}},{\\\"contract\\\":\\\"market\\\",\\\"event\\\":\\\"orderClosed\\\",\\\"data\\\":{\\\"account\\\":\\\"sm-usd\\\",\\\"type\\\":\\\"buy\\\",\\\"txId\\\":\\\"bc4cb51907cae107671f6f22a8207fb31c660d74\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"4800.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"DEC\\\",\\\"quantity\\\":\\\"4800.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"22.15240731\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"LEO\\\",\\\"quantity\\\":\\\"40.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"30.00042338\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"LEO\\\",\\\"quantity\\\":\\\"40.000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"SWAP.BTC\\\",\\\"quantity\\\":\\\"0.00045000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"SWAP.BTC\\\",\\\"quantity\\\":\\\"0.00045000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"35.00000002\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"35.00000001\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"9.99999890\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferFromContract\\\",\\\"data\\\":{\\\"from\\\":\\\"market\\\",\\\"to\\\":\\\"mmmmkkkk311\\\",\\\"symbol\\\":\\\"SWAP.LTC\\\",\\\"quantity\\\":\\\"0.03600000\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"SWAP.HIVE\\\",\\\"quantity\\\":\\\"9.99999929\\\"}},{\\\"contract\\\":\\\"tokens\\\",\\\"event\\\":\\\"transferToContract\\\",\\\"data\\\":{\\\"from\\\":\\\"mmmmkkkk311\\\",\\\"to\\\":\\\"market\\\",\\\"symbol\\\":\\\"SWAP.LTC\\\",\\\"quantity\\\":\\\"0.03600000\\\"}}]}\",\"timestamp\":\"2020-10-03T18:32:36\"}")
    
    Transaction.meeseeker_ingest(10, ctx) do |trx, key|
      n, b, t, i = key.split(':')
      
      assert_equal t, trx.trx_id
      assert trx.persisted?
    end
    
    # Repeat on the same context to check dupe logic.
    processed = Transaction.meeseeker_ingest(10, ctx) do |trx|
      assert trx.persisted?
    end
  end
  
  def test_parse_contracts_unsupported
    transaction = Transaction.new(contract: 'WRONG', action: 'WRONG')
    
    assert_nil transaction.send(:parse_contract), 'expect unsupported contract to be skipped'
  end
  
  def test_with_symbol
    refute Transaction.with_symbol.any?
  end
  
  def test_with_symbol_token
    refute Transaction.with_symbol('ENG', :token).any?
  end
  
  def test_with_symbol_nft
    refute Transaction.with_symbol('PFG', :nft).any?
  end
  
  def test_contract_deploys_or_updates
    refute Transaction.contract_deploys_or_updates.any?
  end
  
  def test_contract_deploys_or_updates_with_logs_errors
    assert Transaction.contract_deploys_or_updates(with_logs_errors: true).any?
  end
end
