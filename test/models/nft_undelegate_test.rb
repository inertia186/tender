require "test_helper"

class NftUndelegateTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_undelegate_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_undelegate = @transaction.nft_undelegates.last
  end
  
  def test_validate
    @nft_undelegate.save
    
    assert @nft_undelegate.persisted?, 'expect persisted nft_undelegate'
  end
  
  def test_validate_fail
    nft_undelegate = NftUndelegate.new
    nft_undelegate.save
    
    refute nft_undelegate.persisted?, 'did not expect persisted nft_undelegate'
  end
  
  def test_hydrated_nfts
    assert @nft_undelegate.hydrated_nfts
  end
end
