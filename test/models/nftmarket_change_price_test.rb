require "test_helper"

class NftmarketChangePriceTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nftmarket_change_price_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nftmarket_change_price = @transaction.nftmarket_change_prices.last
  end
  
  def test_validate
    @nftmarket_change_price.save
    
    assert @nftmarket_change_price.persisted?, 'expect persisted nftmarket_change_price'
  end
  
  def test_validate_fail
    nftmarket_change_price = NftmarketChangePrice.new
    nftmarket_change_price.save
    
    refute nftmarket_change_price.persisted?, 'did not expect persisted nftmarket_change_price'
  end
  
  def test_hydrated_nfts
    assert @nftmarket_change_price.hydrated_nfts
  end
end
