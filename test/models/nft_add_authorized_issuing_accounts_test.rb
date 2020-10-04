require "test_helper"

class NftAddAuthorizedIssuingAccountsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:nft_add_authorized_issuing_accounts)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @nft_add_authorized_issuing_accounts = @transaction.nft_add_authorized_issuing_accounts.last
  end
  
  def test_validate
    @nft_add_authorized_issuing_accounts.save
    
    assert @nft_add_authorized_issuing_accounts.persisted?, 'expect persisted nft_add_authorized_issuing_accounts'
  end
  
  def test_validate_fail
    nft_add_authorized_issuing_accounts = NftAddAuthorizedIssuingAccounts.new
    nft_add_authorized_issuing_accounts.save
    
    refute nft_add_authorized_issuing_accounts.persisted?, 'did not expect persisted nft_add_authorized_issuing_accounts'
  end
  
  def test_hydrated_accounts
    assert @nft_add_authorized_issuing_accounts.hydrated_accounts
  end
end
