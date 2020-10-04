require "test_helper"

class NftRemoveAuthorizedIssuingContractsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_remove_authorized_issuing_contracts) rescue skip('no fixture defined')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_remove_authorized_issuing_contracts = @transaction.nft_remove_authorized_issuing_contracts.last
  end
  
  def test_validate
    @nft_remove_authorized_issuing_contracts.save
    
    assert @nft_remove_authorized_issuing_contracts.persisted?, 'expect persisted nft_remove_authorized_issuing_contracts'
  end
  
  def test_validate_fail
    nft_remove_authorized_issuing_contracts = NftRemoveAuthorizedIssuingContracts.new
    nft_remove_authorized_issuing_contracts.save
    
    refute nft_remove_authorized_issuing_contracts.persisted?, 'did not expect persisted nft_remove_authorized_issuing_contracts'
  end
  
  def test_hydrated_contracts
    assert @nft_remove_authorized_issuing_contracts.hydrated_contracts
  end
end
