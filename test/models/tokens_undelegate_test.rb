require "test_helper"

class TokensUndelegateTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_undelegate)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_undelegate = @transaction.tokens_undelegates.last
  end
  
  def test_validate
    @tokens_undelegate.save
    
    assert @tokens_undelegate.persisted?, 'expect persisted tokens_undelegate'
  end
  
  def test_validate_fail
    tokens_undelegate = TokensUndelegate.new
    tokens_undelegate.save
    
    refute tokens_undelegate.persisted?, 'did not expect persisted tokens_undelegate'
  end
end
