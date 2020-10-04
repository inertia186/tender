require "test_helper"

class TokensUnstakeTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_unstake_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_unstake = @transaction.tokens_unstakes.last
  end
  
  def test_validate
    @tokens_unstake.save
    
    assert @tokens_unstake.persisted?, 'expect persisted tokens_unstake'
  end
  
  def test_validate_fail
    tokens_unstake = TokensUnstake.new
    tokens_unstake.save
    
    refute tokens_unstake.persisted?, 'did not expect persisted tokens_unstake'
  end
end
