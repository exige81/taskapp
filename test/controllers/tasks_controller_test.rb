require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
    @user = users(:normal_user)
    sign_in @user
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "only allow signed in users" do
    sign_out @user
    get new_task_url
    assert_redirected_to new_user_session_path
  end

  test "should create task" do
    assert_difference('Task.count') do
      post tasks_url, params: { task: { name: @task.name } }
    end

    assert_redirected_to root_url
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: { task: { name: @task.name } }
    assert_redirected_to root_url
  end

  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete task_url(@task)
    end

    assert_redirected_to root_url
  end

  test "should accept sort param" do
    get '/all'
    assert_response :success
  end

end
