require "test_helper"

class NftEnableDelegationTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_enable_delegation) rescue skip('no fixture defined')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_enable_delegation = @transaction.nft_enable_delegations.last
  end
  
  def test_validate
    @nft_enable_delegation.save
    
    assert @nft_enable_delegation.persisted?, 'expect persisted nft_enable_delegation'
  end
  
  def test_validate_fail
    nft_enable_delegation = NftEnableDelegation.new
    nft_enable_delegation.save
    
    refute nft_enable_delegation.persisted?, 'did not expect persisted nft_enable_delegation'
  end
end
