require "test_helper"

class TokensEnableStakingTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_enable_staking_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_enable_staking = @transaction.tokens_enable_stakings.last
  end
  
  def test_validate
    @tokens_enable_staking.save
    
    assert @tokens_enable_staking.persisted?, 'expect persisted tokens_enable_staking'
  end
  
  def test_validate_fail
    tokens_enable_staking = TokensEnableStaking.new
    tokens_enable_staking.save
    
    refute tokens_enable_staking.persisted?, 'did not expect persisted tokens_enable_staking'
  end
end
