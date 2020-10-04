require "test_helper"

class TokensTransferOwnershipTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_transfer_ownership_alice_bob_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_transfer_ownership = @transaction.tokens_transfer_ownerships.last
  end
  
  def test_validate
    @tokens_transfer_ownership.save
    
    assert @tokens_transfer_ownership.persisted?, 'expect persisted tokens_transfer_ownership'
  end
  
  def test_validate_fail
    tokens_transfer_ownership = TokensTransferOwnership.new
    tokens_transfer_ownership.save
    
    refute tokens_transfer_ownership.persisted?, 'did not expect persisted tokens_transfer_ownership'
  end
end
