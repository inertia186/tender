require "test_helper"

class TokensCheckPendingUndelegationsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_check_pending_undelegations)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_check_pending_undelegations = @transaction.tokens_check_pending_undelegations.last
  end
  
  def test_validate
    @tokens_check_pending_undelegations.save
    
    assert @tokens_check_pending_undelegations.persisted?, 'expect persisted tokens_check_pending_undelegations'
  end
  
  def test_validate_fail
    tokens_check_pending_undelegations = TokensCheckPendingUndelegations.new
    tokens_check_pending_undelegations.save
    
    refute tokens_check_pending_undelegations.persisted?, 'did not expect persisted tokens_check_pending_undelegations'
  end
end
