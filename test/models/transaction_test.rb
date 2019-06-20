require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @contracts = {
      contract: %i(deploy update),
      market: %i(buy cancel sell),
      sscstore: %i(buy),
      steempegged: %i(buy remove_withdrawal withdraw),
      tokens: %i(cancel_unstake check_pending_unstakes create delegate
        enable_delegation enable_staking issue stake transfer_ownership
        transfer_to_contract transfer undelegate unstake update_metadata
        update_param update_precision update_url)
    }
    
    @skipped_contracts = {
      tokens: %i(transfer_to_contract update_param)
    }
  end
  
  def test_with_logs_errors
    assert Transaction.with_logs_errors.any?, 'expect log errors'
    assert Transaction.with_logs_errors(false).any?, 'expect no log errors'
  end
  
  def test_contract
    assert Transaction.contract(:tokens).any?, 'expect tokens contract transactions'
    assert Transaction.contract(:tokens, invert: true).any?, 'expect non-tokens contract transactions'
    assert Transaction.contract([:tokens, :market]).any?, 'expect compound contract transactions'
    assert Transaction.contract([:tokens, :market], invert: true).any?, 'expect non-compound contract transactions'
  end
  
  def test_virtual
    assert (virtual_trxs = Transaction.virtual).any?, 'expect virtual transactions'
    assert Transaction.virtual(false).any?, 'expect non-virtual transactions'
    assert virtual_trxs.map(&:virtual?).uniq == [true], 'expect virtual transactions to be virtual'
  end
  
  def test_relations
    transaction = Transaction.new
    
    @contracts.each do |contract, actions|
      actions.each do |action|
        relation = "#{contract}_#{action.to_s.pluralize}"
        
        assert transaction.send(relation).empty?, "expect empty relation: #{relation}"
      end
    end
  end
  
  def test_parse_contracts
    Transaction.find_each do |trx|
      trx.send :parse_contract
    end
    
    @contracts.each do |contract, actions|
      actions.each do |action|
        action_name = action.to_s.camelize(:lower)
        trxs = Transaction.where(contract: contract, action: action_name)
        relation = "#{contract}_#{action.to_s.pluralize}"
        
        if !!@skipped_contracts[contract] && !!@skipped_contracts[contract].include?(action)
          # These do not have any examples to test yet.  If we end up finding
          # one, we need to remove it from the skipped contracts.
          
          refute trxs.any?, "did not expect relation for contract: #{contract}, action: #{action_name}"
          refute !!trxs.first && trxs.first.send(relation).present?, "did not expect relation: #{relation}"
        else
          refute trxs.none?, "did not expect empty relation for contract: #{contract}, action: #{action_name}"
          refute trxs.first.send(relation).empty?, "did not expect empty relation: #{relation}"
        end
      end
    end
  end
  
  def test_parse_contracts_unsupported
    transaction = Transaction.new(contract: 'WRONG', action: 'WRONG')
    
    assert_nil transaction.send(:parse_contract), 'expect unsupported contract to be skipped'
  end
end
