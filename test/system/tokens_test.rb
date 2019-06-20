require "application_system_test_case"

class TokensTest < ApplicationSystemTestCase
  setup do
    @tokens_create = transactions(:tokens_create)
  end

  test "visiting the index" do
    visit tokens_url
    assert_selector "h1", text: "Tokens"
  end
end
