require "test_helper"

class NftmarketBuyTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nftmarket_buy_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nftmarket_buy = @transaction.nftmarket_buys.last
  end
  
  def test_validate
    @nftmarket_buy.save
    
    assert @nftmarket_buy.persisted?, 'expect persisted nftmarket_buy'
  end
  
  def test_validate_fail
    nftmarket_buy = NftmarketBuy.new
    nftmarket_buy.save
    
    refute nftmarket_buy.persisted?, 'did not expect persisted nftmarket_buy'
  end
  
  def test_hydrated_nfts
    assert @nftmarket_buy.hydrated_nfts
  end
end
