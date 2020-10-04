require "test_helper"

class NftBurnTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_burn_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_burn = @transaction.nft_burns.last
  end
  
  def test_validate
    @nft_burn.save
    
    assert @nft_burn.persisted?, 'expect persisted nft_burn'
  end
  
  def test_validate_fail
    nft_burn = NftBurn.new
    nft_burn.save
    
    refute nft_burn.persisted?, 'did not expect persisted nft_burn'
  end
  
  def test_hydrated_nfts
    assert @nft_burn.hydrated_nfts
  end
end
