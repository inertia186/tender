require "test_helper"

class NftSetGroupByTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_set_group_by_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_set_group_by = @transaction.nft_set_group_bys.last
  end

  def test_validate
    @nft_set_group_by.save
    
    assert @nft_set_group_by.persisted?, 'expect persisted nft_set_group_by'
  end
  
  def test_validate_fail
    nft_set_group_by = NftSetGroupBy.new
    nft_set_group_by.save
    
    refute nft_set_group_by.persisted?, 'did not expect persisted nft_set_group_by'
  end
  
  def test_hydrated_properties
    assert @nft_set_group_by.hydrated_properties
  end
end
