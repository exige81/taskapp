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
    assert_select 'a[href=?]', new_user_registration_path
    assert_select 'a[href=?]', destroy_user_session_path, count: 0
  end

  test "Home page has logout when logged in" do
    get root_path
    assert_select 'a[href=?]', new_user_session_path, count: 0
    assert_select 'a[href=?]', new_user_registration_path, count: 0
    assert_select 'a[href=?]', destroy_user_session_path
  end

  test "Show tasks on user page" do
    get root_path
    assert_select 'table.tasklist'
    @user.tasks.each do |task|
      assert_select "tr[id=?]",  "task_#{task.id}", count: 1
    end
    assert_select 'td.completed', count: 1
    assert_select 'a[href=?]', edit_task_path( tasks(:one) ), count: 1
    assert_select 'a[href=?]', task_path( tasks(:one) ), text: "Destroy", count: 1
  end

  test "New task form on index page" do
    get root_path
    assert_select 'input#task_name', count: 1
    assert_select 'input[value=?]', "Create Task", count: 1
  end

  test "No completed checkbox for new task form" do
    get edit_task_path(tasks(:one))
    assert_select 'input#task_completed', count: 1
    get new_task_path
    assert_response :success
    assert_select 'input#task_completed', count: 0
  end

end
