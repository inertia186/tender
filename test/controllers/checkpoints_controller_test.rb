require 'test_helper'

class CheckpointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @checkpoint = checkpoints(:genesis)
  end

  test "should get index" do
    get checkpoints_url
    assert_response :success
    
    checkpoints = assigns :checkpoints
    assert checkpoints.include? @checkpoint
  end
end
