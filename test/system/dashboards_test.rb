require "application_system_test_case"

class DashboardsTest < ApplicationSystemTestCase
  setup do
    @dashboard = dashboards(:one)
  end

  test "visiting the index" do
    visit root_url
    assert_selector "h1", text: "Dashboards"
  end
end
