require "test_helper"

class TokensTransferToContractTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_transfer_to_contract)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_transfer_to_contract = @transaction.tokens_transfer_to_contracts.last
  end
  
  def test_validate
    @tokens_transfer_to_contract.save
    
    assert @tokens_transfer_to_contract.persisted?, 'expect persisted tokens_transfer_to_contract'
  end
  
  def test_validate_fail
    tokens_transfer_to_contract = TokensTransferToContract.new
    tokens_transfer_to_contract.save
    
    refute tokens_transfer_to_contract.persisted?, 'did not expect persisted tokens_transfer_to_contract'
  end
end
