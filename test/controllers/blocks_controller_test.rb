require 'test_helper'

class BlocksControllerTest < ActionDispatch::IntegrationTest
  test "should show block" do
    get b_url(0)
    assert_response :success
  end
end
