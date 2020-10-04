require "test_helper"

class TokensTransferTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_transfer_alice_bob_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_transfer = @transaction.tokens_transfers.last
  end
  
  def test_validate
    @tokens_transfer.save
    
    assert @tokens_transfer.persisted?, 'expect persisted tokens_transfer'
  end
  
  def test_validate_fail
    tokens_transfer = TokensTransfer.new
    tokens_transfer.save
    
    refute tokens_transfer.persisted?, 'did not expect persisted tokens_transfer'
  end
end
