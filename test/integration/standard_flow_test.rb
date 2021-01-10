require "test_helper"

class StandardFlowTest < ActionDispatch::IntegrationTest

  test "Home page has devise links" do
    get root_path
    assert_response :success
    assert_select 'a[href=?]', new_user_session_path
    assert_select 'a[href=?]', new_user_registration_path
  end
end
