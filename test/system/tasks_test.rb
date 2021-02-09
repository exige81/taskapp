require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  setup do
    @task = tasks(:one)
    @user = users(:normal_user)
    sign_in @user
  end

  test "visit root url" do
    sign_out @user
    visit root_url
    click_on "Log in"
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_on "Log in"
    assert_selector "h1", text: "You need to do this stuff:"
  end

  test "Create a new task" do
    visit root_url

    fill_in "Name", with: "A Test Task"
    click_on "Create Task"

    assert_selector 'td', text: "A Test Task"
  end

  test "Mark task complete and uncomplete" do
    visit root_url
    check "toggle_task_#{@task.id}"
    within "tr#task_#{@task.id}" do
      assert_selector "td.completed", count: 1
    end
    uncheck "toggle_task_#{@task.id}"
    within "tr#task_#{@task.id}" do
      assert_selector "td.completed", count: 0
    end
  end

  # test "updating a Task" do
  #   visit tasks_url
  #   click_on "Edit", match: :first

  #   check "Completed" if @task.completed
  #   # fill_in "Completed at", with: @task.completed_at
  #   fill_in "Name", with: @task.name
  #   click_on "Update Task"

  #   assert_text "Task was successfully updated"
  # end

  # test "destroying a Task" do
  #   visit tasks_url
  #   page.accept_confirm do
  #     click_on "Destroy", match: :first
  #   end

  #   assert_text "Task was successfully destroyed"
  # end
end
