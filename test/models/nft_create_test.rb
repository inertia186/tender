require "test_helper"

class NftCreateTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_create)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_create = @transaction.nft_creates.last
  end
  
  def test_validate
    @nft_create.authorized_issuing_accounts = '["inertia"]'
    @nft_create.save
    
    assert @nft_create.persisted?, 'expect persisted nft_create'
  end
  
  def test_validate_fail
    nft_create = NftCreate.new
    nft_create.save
    
    refute nft_create.persisted?, 'did not expect persisted nft_create'
  end
  
  def test_hydrated_authorized_issuing_accounts
    assert @nft_create.hydrated_authorized_issuing_accounts
  end
end
