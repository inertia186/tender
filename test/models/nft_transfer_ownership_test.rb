require "test_helper"

class NftTransferOwnershipTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_transfer_ownership) rescue skip('no fixture defined')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_transfer_ownership = @transaction.nft_transfer_ownerships.last
  end
  
  def test_validate
    @nft_transfer_ownership.save
    
    assert @nft_transfer_ownership.persisted?, 'expect persisted nft_transfer_ownership'
  end
  
  def test_validate_fail
    nft_transfer_ownership = NftTransferOwnership.new
    nft_transfer_ownership.save
    
    refute nft_transfer_ownership.persisted?, 'did not expect persisted nft_transfer_ownership'
  end
end
