require "test_helper"

class TokensUpdateMetadataTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  
  def setup
    @transaction = transactions(:genesis_tokens_update_metadata)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_update_metadata = @transaction.tokens_update_metadata.last
  end
  
  def test_validate
    @tokens_update_metadata.save
    
    assert @tokens_update_metadata.persisted?, 'expect persisted tokens_update_metadata'
  end
  
  def test_validate_fail
    tokens_update_metadata = TokensUpdateMetadata.new
    tokens_update_metadata.save
    
    refute tokens_update_metadata.persisted?, 'did not expect persisted tokens_update_metadata'
  end
end
