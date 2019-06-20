require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = transactions(:genesis_null_null)
  end
  
  test 'should get index' do
    get transactions_url
    assert_response :success
  end
  
  test 'should get index for account' do
    get transactions_url(account: 'alice')
    assert_response :success
  end
  
  test 'should get index for symbol' do
    get transactions_url(symbol: 'eng')
    assert_response :success
  end
  
  test 'should get index for account and symbol' do
    get transactions_url(account: 'alice', symbol: 'eng')
    assert_response :success
  end
  
  test 'should get index for general search' do
    get transactions_url(search: 'search')
    assert_response :success
  end
  
  test 'should get index for search account' do
    get transactions_url(search: '@alice')
    assert_redirected_to account_home_url('alice')
  end
  
  test 'should get index for search symbol' do
    get transactions_url(search: '$eng')
    assert_redirected_to transactions_url(symbol: 'eng')
  end
  
  test 'should get index for search trx_id' do
    get transactions_url(search: '0000000000000000000000000000000000000000')
    assert_redirected_to tx_url('0000000000000000000000000000000000000000')
  end
  
  test 'should get index for search block_num' do
    get transactions_url(search: '0')
    assert_redirected_to b_url(0)
  end
  
  test 'should get index for open orders' do
    get transactions_url(open_orders: 'true')
    assert_response :success
  end
  
  test 'should get index for open orders for account' do
    get transactions_url(open_orders: 'true', account: 'alice')
    assert_response :success
  end
  
  # test 'should get index for open orders for multiple accounts' do
  #   get transactions_url(open_orders: 'true', account: ['alice', 'bob'])
  #   assert_response :success
  # end
  
  test 'should get index for open orders for symbol' do
    get transactions_url(open_orders: 'true', symbol: 'eng')
    assert_response :success
  end
  
  test 'should get index for open orders for account and symbol' do
    get transactions_url(open_orders: 'true', account: 'alice', symbol: 'eng')
    assert_response :success
  end
  
  test 'should show open orders' do
    get open_orders_url('alice')
    assert_response :success
  end
  
  test 'should show transaction' do
    get tx_url(@transaction)
    assert_response :success
  end
end
