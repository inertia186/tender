require "test_helper"

class NftAddPropertyTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_add_property_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_add_property = @transaction.nft_add_properties.last
  end
  
  def test_validate
    @nft_add_property.save
    
    assert @nft_add_property.persisted?, 'expect persisted nft_add_property'
  end
  
  def test_validate_fail
    nft_add_property = NftAddProperty.new
    nft_add_property.save
    
    refute nft_add_property.persisted?, 'did not expect persisted nft_add_property'
  end
  
  def test_hydrated_authorized_issuing_accounts
    assert @nft_add_property.hydrated_authorized_issuing_accounts
  end
end
