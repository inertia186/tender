require "test_helper"

class MarketCancelTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:market_cancel_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @market_cancel = @transaction.market_cancels.last
  end
  
  def test_validate
    @market_cancel.save
    
    assert @market_cancel.persisted?, 'expect persisted market_cancel'
  end
  
  def test_validate_fail
    market_cancel = MarketCancel.new
    market_cancel.save
    
    refute market_cancel.persisted?, 'did not expect persisted market_cancel'
  end
end
