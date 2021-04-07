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
    # click_link "Log in"
    click_link "login_link"
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_button "Log in"
    assert_selector "h1", text: "You need to do this stuff:"
  end

  test "Create a new task" do
    visit root_url

    fill_in "Name", with: "A Test Task"
    click_on "Add Task"

    assert_selector 'div', text: "A Test Task"
  end

  test "Mark task complete and uncomplete" do
    visit '/all'
    check "toggle_task_#{@task.id}"
    within "div#task_#{@task.id}" do
      assert_selector "div.completed", count: 1
    end
    uncheck "toggle_task_#{@task.id}"
    within "div#task_#{@task.id}" do
      assert_selector "div.completed", count: 0
    end
  end

  test "View sorted tasks" do
    visit root_url
    assert_selector "div#task_#{@task.id}", count: 1
    assert_selector "div.completed", count: 1
    click_on "Completed"
    assert_selector "div.completed", count: 1
    assert_selector "div#task_#{@task.id}", count: 0
    click_on "Incomplete"
    assert_selector "div#task_#{@task.id}", count: 0
    assert_selector "div.completed", count: 0
  end

  test "updating a Task" do
    visit tasks_url
    click_on "Edit", match: :first

    check "Completed" if @task.completed
    # fill_in "Completed at", with: @task.completed_at
    fill_in "Name", with: @task.name
    click_on "Update Task"

    assert_text "Task was successfully updated"
  end

  test "destroying a Task" do
    visit tasks_url
    page.accept_confirm do
      click_on "delete_task_#{@task.id}", match: :first
    end

    assert_text "Task was successfully destroyed"
  end

  test "editing a task" do
    skip
  end
end
