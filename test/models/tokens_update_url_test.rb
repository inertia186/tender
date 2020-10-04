require "test_helper"

class TokensUpdateUrlTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:tokens_update_url_alice_eng)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_update_url = @transaction.tokens_update_urls.last
  end
  
  def test_validate
    @tokens_update_url.save
    
    assert @tokens_update_url.persisted?, 'expect persisted tokens_update_url'
  end
  
  def test_validate_fail
    tokens_update_url = TokensUpdateUrl.new
    tokens_update_url.save
    
    refute tokens_update_url.persisted?, 'did not expect persisted tokens_update_url'
  end
end
