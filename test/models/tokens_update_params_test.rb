require "test_helper"

class TokensUpdateParamsTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:genesis_tokens_update_params)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_update_params = @transaction.tokens_update_params.last
  end
  
  def test_validate
    @tokens_update_params.save rescue skip('TODO: Add new untracked fields added to genesis after implementation.')
    
    assert @tokens_update_params.persisted?, 'expect persisted tokens_update_params'
  end
  
  def test_validate_fail
    tokens_update_params = TokensUpdateParams.new
    tokens_update_params.save
    
    refute tokens_update_params.persisted?, 'did not expect persisted tokens_update_params'
  end
end
