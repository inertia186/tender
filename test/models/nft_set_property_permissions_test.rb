require "test_helper"

class NftSetPropertyPermissionsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_set_property_permission)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_set_property_permission = @transaction.nft_set_property_permissions.last
  end
  
  def test_validate
    @nft_set_property_permission.save
    
    assert @nft_set_property_permission.persisted?, 'expect persisted nft_set_property_permissions'
  end
  
  def test_validate_fail
    nft_set_property_permission = NftSetPropertyPermissions.new
    nft_set_property_permission.save
    
    refute nft_set_property_permission.persisted?, 'did not expect persisted nft_set_property_permissions'
  end
  
  def test_hydrated_accounts
    assert @nft_set_property_permission.hydrated_accounts
  end
  
  def test_hydrated_contracts
    assert @nft_set_property_permission.hydrated_contracts
  end
end
