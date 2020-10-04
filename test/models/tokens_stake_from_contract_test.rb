require "test_helper"

class FromkensStakeFromContractTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_stake_from_contract) rescue skip('TODO: Add table.')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_stake_from_contract = @transaction.tokens_stake_from_contracts.last
  end
  
  def test_validate
    @tokens_stake_from_contract.save
    
    assert @tokens_stake_from_contract.persisted?, 'expect persisted tokens_stake_from_contract'
  end
  
  def test_validate_fail
    tokens_stake_from_contract = FromkensStakeFromContract.new
    tokens_stake_from_contract.save
    
    refute tokens_stake_from_contract.persisted?, 'did not expect persisted tokens_stake_from_contract'
  end
end
