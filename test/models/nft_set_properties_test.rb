require "test_helper"

class NftSetPropertiesTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_set_properties_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_set_properties = @transaction.nft_set_properties.last
  end
  
  def test_scoped_symbol
    assert NftSetProperties.symbol('ABC').none?, 'expect none by symbol'
    assert NftSetProperties.symbol('ABC', invert: true).any?, 'expect any by symbol inverted'
  end

  def test_validate
    @nft_set_properties.save
    
    assert @nft_set_properties.persisted?, 'expect persisted nft_set_properties'
  end
  
  def test_validate_fail
    nft_set_properties = NftSetProperties.new
    nft_set_properties.save
    
    refute nft_set_properties.persisted?, 'did not expect persisted nft_set_properties'
  end
  
  def test_hydrated_nfts
    assert @nft_set_properties.hydrated_nfts
  end
end
