require "test_helper"

class NftDelegateTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_delegate_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_delegate = @transaction.nft_delegates.last
  end
  
  def test_validate
    @nft_delegate.save
    
    assert @nft_delegate.persisted?, 'expect persisted nft_delegate'
  end
  
  def test_validate_fail
    nft_delegate = NftDelegate.new
    nft_delegate.save
    
    refute nft_delegate.persisted?, 'did not expect persisted nft_delegate'
  end
  
  def test_hydrated_nfts
    assert @nft_delegate.hydrated_nfts
  end
  
  def test_to_param
    assert @transaction.to_param
    assert @nft_delegate.to_param
  end
end
