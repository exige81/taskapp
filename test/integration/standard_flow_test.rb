require "test_helper"

class StandardFlowTest < ActionDispatch::IntegrationTest

  test "Home page has devise links" do
    get root_path
    assert_response :success
    assert_select 'a[href=?]', new_user_session_path
    assert_select 'a[href=?]', new_user_registration_path
    assert_select 'a[href=?]', destroy_user_session_path, count: 0
  end

  test "Home page has logout when logged in" do
    sign_in users(:normal_user)
    get root_path
    assert_select 'a[href=?]', new_user_session_path, count: 0
    assert_select 'a[href=?]', new_user_registration_path, count: 0
    assert_select 'a[href=?]', destroy_user_session_path
  end
end
