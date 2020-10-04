require "test_helper"

class TokensStakeTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_stake_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_stake = @transaction.tokens_stakes.last
  end
  
  def test_validate
    @tokens_stake.save
    
    assert @tokens_stake.persisted?, 'expect persisted tokens_stake'
  end
  
  def test_validate_fail
    tokens_stake = TokensStake.new
    tokens_stake.save
    
    refute tokens_stake.persisted?, 'did not expect persisted tokens_stake'
  end
end
