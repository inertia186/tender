require "test_helper"

class NftmarketCancelTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nftmarket_cancel_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nftmarket_cancel = @transaction.nftmarket_cancels.last
  end
  
  def test_validate
    @nftmarket_cancel.save
    
    assert @nftmarket_cancel.persisted?, 'expect persisted nftmarket_cancel'
  end
  
  def test_validate_fail
    nftmarket_cancel = NftmarketCancel.new
    nftmarket_cancel.save
    
    refute nftmarket_cancel.persisted?, 'did not expect persisted nftmarket_cancel'
  end
  
  def test_hydrated_nfts
    assert @nftmarket_cancel.hydrated_nfts
  end
end
