require "test_helper"

class MarketSellTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:market_sell_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @market_sell = @transaction.market_sells.last
  end
  
  def test_validate
    @market_sell.save
    
    assert @market_sell.persisted?, 'expect persisted market_sell'
  end
  
  def test_validate_fail
    market_sell = MarketSell.new
    market_sell.save
    
    refute market_sell.persisted?, 'did not expect persisted market_sell'
  end
end
