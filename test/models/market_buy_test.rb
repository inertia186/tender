require "test_helper"

class MarketBuyTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:market_buy_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @market_buy = @transaction.market_buys.last
  end
  
  def test_validate
    @market_buy.save
    
    assert @market_buy.persisted?, 'expect persisted market_buy'
  end
  
  def test_validate_fail
    market_buy = MarketBuy.new
    market_buy.save
    
    refute market_buy.persisted?, 'did not expect persisted market_buy'
  end
end
