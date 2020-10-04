require "test_helper"

class TokensCreateTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:genesis_tokens_create)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_create = @transaction.tokens_creates.last
  end
  
  def test_validate
    @tokens_create.save
    
    assert @tokens_create.persisted?, 'expect persisted tokens_create'
  end
  
  def test_validate_fail
    tokens_create = TokensCreate.new
    tokens_create.save
    
    refute tokens_create.persisted?, 'did not expect persisted tokens_create'
  end
end
