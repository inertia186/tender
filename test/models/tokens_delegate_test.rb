require "test_helper"

class TokensDelegateTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_delegate)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_delegate = @transaction.tokens_delegates.last
  end
  
  def test_validate
    @tokens_delegate.save
    
    assert @tokens_delegate.persisted?, 'expect persisted tokens_delegate'
  end
  
  def test_validate_fail
    tokens_delegate = TokensDelegate.new
    tokens_delegate.save
    
    refute tokens_delegate.persisted?, 'did not expect persisted tokens_delegate'
  end
end
