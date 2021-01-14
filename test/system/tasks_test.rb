require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  setup do
    @task = tasks(:one)
    sign_in users(:normal_user)
  end

  test "visiting the index" do
    visit tasks_url
    assert_selector "h1", text: "Tasks"
  end

  test "creating a Task" do
    visit tasks_url
    click_on "New Task"

    fill_in "Name", with: @task.name
    click_on "Create Task"

    assert_text "Task was successfully created"
    assert_text @task.name
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
      click_on "Destroy", match: :first
    end

    assert_text "Task was successfully destroyed"
  end
end
