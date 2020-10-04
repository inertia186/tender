require "test_helper"

class NftIssueTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_issue_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_issue = @transaction.nft_issues.last
  end
  
  def test_validate
    @nft_issue.save
    
    assert @nft_issue.persisted?, 'expect persisted nft_issue'
  end
  
  def test_validate_fail
    nft_issue = NftIssue.new
    nft_issue.save
    
    refute nft_issue.persisted?, 'did not expect persisted nft_issue'
  end
  
  def test_hydrated_lock_tokens
    assert @nft_issue.hydrated_lock_tokens
  end
  
  def test_hydrated_properties
    assert @nft_issue.hydrated_properties
  end
end
