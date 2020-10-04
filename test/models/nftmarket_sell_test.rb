require "test_helper"

class NftmarketSellTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nftmarket_sell_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nftmarket_sell = @transaction.nftmarket_sells.last
  end
  
  def test_validate
    @nftmarket_sell.save
    
    assert @nftmarket_sell.persisted?, 'expect persisted nftmarket_sell'
  end
  
  def test_validate_fail
    nftmarket_sell = NftmarketSell.new
    nftmarket_sell.save
    
    refute nftmarket_sell.persisted?, 'did not expect persisted nftmarket_sell'
  end
  
  def test_hydrated_nfts
    assert @nftmarket_sell.hydrated_nfts
  end
end
