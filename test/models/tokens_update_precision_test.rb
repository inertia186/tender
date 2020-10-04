require "test_helper"

class TokensUpdatePrecisionTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_update_precisions_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_update_precision = @transaction.tokens_update_precisions.last
  end
  
  def test_validate
    @tokens_update_precision.save
    
    assert @tokens_update_precision.persisted?, 'expect persisted tokens_update_precision'
  end
  
  def test_validate_fail
    tokens_update_precision = TokensUpdatePrecision.new
    tokens_update_precision.save
    
    refute tokens_update_precision.persisted?, 'did not expect persisted tokens_update_precision'
  end
end
