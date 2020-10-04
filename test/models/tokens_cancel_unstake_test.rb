require "test_helper"

class TokensCancelUnstakeTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_cancel_unstake_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_cancel_unstake = @transaction.tokens_cancel_unstakes.last
  end
  
  def test_validate
    @tokens_cancel_unstake.save
    
    assert @tokens_cancel_unstake.persisted?, 'expect persisted tokens_cancel_unstake'
  end
  
  def test_validate_fail
    tokens_cancel_unstake = TokensCancelUnstake.new
    tokens_cancel_unstake.save
    
    refute tokens_cancel_unstake.persisted?, 'did not expect persisted tokens_cancel_unstake'
  end
end
