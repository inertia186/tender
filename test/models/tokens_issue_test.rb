require "test_helper"

class TokensIssueTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_issue_alice_bob_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_issue = @transaction.tokens_issues.last
  end
  
  def test_validate
    @tokens_issue.save
    
    assert @tokens_issue.persisted?, 'expect persisted tokens_issue'
  end
  
  def test_validate_fail
    tokens_issue = TokensIssue.new
    tokens_issue.save
    
    refute tokens_issue.persisted?, 'did not expect persisted tokens_issue'
  end
end
