require "test_helper"

class StandardFlowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:normal_user)
    sign_in @user
  end

  test "Home page has devise links" do
    sign_out @user
    get root_path
    assert_response :success
    assert_select 'a[href=?]', new_user_session_path
    assert_select 'a', text: /sign up/i, count: 0
    assert_select 'a[href=?]', destroy_user_session_path, count: 0
  end

  test "Home page has logout when logged in" do
    get root_path
    assert_select 'a[href=?]', new_user_session_path, count: 0
    assert_select 'a[href=?]', destroy_user_session_path
  end

  test "Public sign-up and password reset are disabled" do
    sign_out @user
    get "/users/sign_up"
    assert_response :not_found
    get "/users/password/new"
    assert_response :not_found
  end

  test "Account locks after repeated failed logins and unlocks after unlock_in" do
    sign_out @user
    get new_user_session_path # warm up the session before counting attempts
    Devise.maximum_attempts.times do
      post user_session_path, params: { user: { email: @user.email, password: "wrong" } }
    end
    assert @user.reload.access_locked?

    travel Devise.unlock_in + 1.minute do
      assert_not @user.reload.access_locked?
    end
  end

  test "Show tasks on user page" do
    get root_path
    assert_select 'div#tasklist'
    assert_select "div[id=?]",  "task_#{tasks(:one).id}", count: 1
    assert_select 'div.completed', count: 1
    assert_select 'a[href=?]', edit_task_path( tasks(:one) ), count: 1
    assert_select 'a[href=?]', task_path( tasks(:one) ), count: 1
  end

  test "New task form on index page" do
    get root_path
    assert_select 'input#task_name', count: 1
    assert_select 'input[value=?]', "Add Task", count: 1
  end

  test "Completed page should only show completed tasks" do
    get '/completed'
    assert_select "div[id=?]",  "task_#{tasks(:completed_task).id}", count: 1
    assert_select "div[id=?]",  "task_#{tasks(:one).id}", count: 0
  end

  test "All page should only show all tasks" do
    get '/all'
    assert_select "div[id=?]",  "task_#{tasks(:completed_task).id}", count: 1
    assert_select "div[id=?]",  "task_#{tasks(:one).id}", count: 1
  end

end
