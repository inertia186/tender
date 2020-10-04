require "test_helper"

class TokensEnableDelegationTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_enable_delegation_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_enable_delegation = @transaction.tokens_enable_delegations.last
  end
  
  def test_validate
    @tokens_enable_delegation.save
    
    assert @tokens_enable_delegation.persisted?, 'expect persisted tokens_enable_delegation'
  end
  
  def test_validate_fail
    tokens_enable_delegation = TokensEnableDelegation.new
    tokens_enable_delegation.save
    
    refute tokens_enable_delegation.persisted?, 'did not expect persisted tokens_enable_delegation'
  end
end
