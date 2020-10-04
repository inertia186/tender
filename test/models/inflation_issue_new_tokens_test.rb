require "test_helper"

class InflationIssueNewTokensTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:inflation_issue_new_tokens)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @inflation_issue_new_token = @transaction.inflation_issue_new_tokens.last
  end
  
  def test_validate
    @inflation_issue_new_token.save
    
    assert @inflation_issue_new_token.persisted?, 'expect persisted inflation_issue_new_token'
  end
  
  def test_validate_fail
    inflation_issue_new_token = InflationIssueNewTokens.new
    inflation_issue_new_token.save
    
    refute inflation_issue_new_token.persisted?, 'did not expect persisted inflation_issue_new_token'
  end
end
