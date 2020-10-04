require "test_helper"

class NftAddAuthorizedIssuingContractsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_add_authorized_issuing_contracts) rescue skip('no fixture defined')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_add_authorized_issuing_contracts = @transaction.nft_add_authorized_issuing_contracts.last
  end
  
  def test_validate
    @nft_add_authorized_issuing_contracts.save
    
    assert @nft_add_authorized_issuing_contracts.persisted?, 'expect persisted nft_add_authorized_issuing_contracts'
  end
  
  def test_validate_fail
    nft_add_authorized_issuing_contracts = NftAddAuthorizedIssuingContracts.new
    nft_add_authorized_issuing_contracts.save
    
    refute nft_add_authorized_issuing_contracts.persisted?, 'did not expect persisted nft_add_authorized_issuing_contracts'
  end
  
  def test_hydrated_contracts
    assert @nft_add_authorized_issuing_contracts.hydrated_contracts
  end
end
