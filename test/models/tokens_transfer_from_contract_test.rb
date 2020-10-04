require "test_helper"

class TokensTransferFromContractTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_transfer_from_contract) rescue skip('TODO: Add table.')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_transfer_from_contract = @transaction.tokens_transfer_from_contracts.last
  end
  
  def test_validate
    @tokens_transfer_from_contract.save
    
    assert @tokens_transfer_from_contract.persisted?, 'expect persisted tokens_transfer_from_contract'
  end
  
  def test_validate_fail
    tokens_transfer_from_contract = TokensTransferFromContract.new
    tokens_transfer_from_contract.save
    
    refute tokens_transfer_from_contract.persisted?, 'did not expect persisted tokens_transfer_from_contract'
  end
end
