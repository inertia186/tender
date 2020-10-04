require "test_helper"

class TokensCheckPendingUnstakesTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_check_pending_unstakes)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_check_pending_unstakes = @transaction.tokens_check_pending_unstakes.last
  end
  
  def test_validate
    @tokens_check_pending_unstakes.save
    
    assert @tokens_check_pending_unstakes.persisted?, 'expect persisted tokens_check_pending_unstakes'
  end
  
  def test_validate_fail
    tokens_check_pending_unstakes = TokensCheckPendingUnstakes.new
    tokens_check_pending_unstakes.save
    
    refute tokens_check_pending_unstakes.persisted?, 'did not expect persisted tokens_check_pending_unstakes'
  end
end
