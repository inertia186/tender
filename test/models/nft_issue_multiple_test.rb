require "test_helper"

class NftIssueMultipleTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_issue_multiple_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_issue_multiple = @transaction.nft_issue_multiples.last
  end
  
  def test_validate
    @nft_issue_multiple.save
    
    assert @nft_issue_multiple.persisted?, 'expect persisted nft_issue_multiple'
  end
  
  def test_validate_fail
    nft_issue_multiple = NftIssueMultiple.new
    nft_issue_multiple.save
    
    refute nft_issue_multiple.persisted?, 'did not expect persisted nft_issue_multiple'
  end
  
  def test_hydrated_instances
    assert @nft_issue_multiple.hydrated_instances
  end
end
