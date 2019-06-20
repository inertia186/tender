require "application_system_test_case"

class CheckpointsTest < ApplicationSystemTestCase
  setup do
    @checkpoint = checkpoints(:one)
  end

  test "visiting the index" do
    visit checkpoints_url
    assert_selector "h1", text: "Checkpoints"
  end
end
