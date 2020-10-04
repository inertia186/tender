require 'test_helper'

class RichlistControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:genesis_tokens_create)
    @transaction.send :parse_error
    @transaction.send :parse_contract
    @tokens_create = @transaction.tokens_creates.last
  end
  
  test 'should get index' do
    get token_richlist_index_url(@tokens_create.symbol)
    assert_response :success
  end
  
  test 'should get index csv' do
    get token_richlist_index_url(@tokens_create.symbol, format: 'csv')
    assert_response :success
  end
  
  test 'should get index sorted' do
    %w(account_name balance stake pending_unstake delegations_out delegations_in influence owned bogus).each do |sort_field|
      get token_richlist_index_url(@tokens_create.symbol, sort_field: sort_field)
      assert_response :success
    end
  end
end
