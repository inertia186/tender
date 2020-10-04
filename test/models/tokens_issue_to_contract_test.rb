require "test_helper"

class TokensIssueToContractTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_issue_to_contract_alice_bob_eng) rescue skip('TODO: Add table.')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_issue_to_contract = @transaction.tokens_issue_to_contracts.last
  end
  
  def test_validate
    @tokens_issue_to_contract.save
    
    assert @tokens_issue_to_contract.persisted?, 'expect persisted tokens_issue_to_contract'
  end
  
  def test_validate_fail
    tokens_issue_to_contract = TokensIssueToContract.new
    tokens_issue_to_contract.save
    
    refute tokens_issue_to_contract.persisted?, 'did not expect persisted tokens_issue_to_contract'
  end
end
