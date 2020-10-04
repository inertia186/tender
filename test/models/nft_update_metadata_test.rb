require "test_helper"

class NftUpdateMetadataTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_update_metadata)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_update_metadata = @transaction.nft_update_metadata.last
  end
  
  def test_validate
    @nft_update_metadata.save
    
    assert @nft_update_metadata.persisted?, 'expect persisted nft_update_metadata'
  end
  
  def test_validate_fail
    nft_update_metadata = NftUpdateMetadata.new
    nft_update_metadata.save
    
    refute nft_update_metadata.persisted?, 'did not expect persisted nft_update_metadata'
  end
  
  def test_hydrated_metadata
    assert @nft_update_metadata.hydrated_metadata
  end
end
