require "test_helper"

class NftRemoveAuthorizedIssuingAccountsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_remove_authorized_issuing_accounts) rescue skip('no fixture defined')
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_remove_authorized_issuing_accounts = @transaction.nft_remove_authorized_issuing_accounts.last
  end
  
  def test_validate
    @nft_remove_authorized_issuing_accounts.save
    
    assert @nft_remove_authorized_issuing_accounts.persisted?, 'expect persisted nft_remove_authorized_issuing_accounts'
  end
  
  def test_validate_fail
    nft_remove_authorized_issuing_accounts = NftRemoveAuthorizedIssuingAccounts.new
    nft_remove_authorized_issuing_accounts.save
    
    refute nft_remove_authorized_issuing_accounts.persisted?, 'did not expect persisted nft_remove_authorized_issuing_accounts'
  end
  
  def test_hydrated_accounts
    assert @nft_remove_authorized_issuing_accounts.hydrated_accounts
  end
end
