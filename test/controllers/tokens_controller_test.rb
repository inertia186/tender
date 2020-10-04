require 'test_helper'

class TokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:genesis_tokens_create)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_create = @transaction.tokens_creates.last
  end

  test "should get index tokens" do
    get tokens_url
    assert_response :success
  end
  
  test "should get index tokens only stake enabled" do
    get tokens_url(only_stake_enabled: 'true')
    assert_response :success
  end
  
  test "should get index tokens except stake enabled" do
    get tokens_url(only_stake_enabled: 'false')
    assert_response :success
  end
  
  test "should get index tokens only scot" do
    get tokens_url(only_scot: 'true')
    assert_response :success
  end

  test "should get index tokens except scot" do
    get tokens_url(only_scot: 'false')
    assert_response :success
  end

  test "should show token" do
    get token_url(@tokens_create.symbol)
    assert_response :success
  end
end
