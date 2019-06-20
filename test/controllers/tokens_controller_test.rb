require 'test_helper'

class TokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:genesis_tokens_create)
    @transaction.send :parse_contract
    @tokens_create = @transaction.tokens_creates.last
  end

  test "should get index" do
    get tokens_url
    assert_response :success
  end

  test "should show token" do
    get token_url(@tokens_create.symbol)
    assert_response :success
  end
end
