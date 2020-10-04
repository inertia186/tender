require "test_helper"

class NftTransferTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_transfer_city)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_transfer = @transaction.nft_transfers.last
  end
  
  def test_scoped_symbol
    assert_raises ActiveRecord::StatementInvalid do
      NftTransfer.symbol('ABC').none?
    end
  end
  
  def test_quantity_sum
    assert_raises ActiveRecord::StatementInvalid do
      NftTransfer.quantity_sum
    end
  end
  
  def test_validate
    @nft_transfer.save
    
    assert @nft_transfer.persisted?, 'expect persisted nft_transfer'
  end
  
  def test_validate_fail
    nft_transfer = NftTransfer.new
    nft_transfer.save
    
    refute nft_transfer.persisted?, 'did not expect persisted nft_transfer'
  end
  
  def test_hydrated_nfts
    assert @nft_transfer.hydrated_nfts
  end
end
