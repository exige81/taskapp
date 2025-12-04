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

  test "completed task sorts bottom" do
    visit '/all'
    # Make sure the task exists
    assert_selector "div#task_#{@task.id}", count: 1

    # Mark the task complete
    check "toggle_task_#{@task.id}"

    # After the reflex runs, the tasklist should be re-rendered and the completed
    rows = page.all('#task-items > .table-row', wait: 5)

    # Find the position of the task we just completed
    idx = rows.find_index { |r| r[:id] == "task_#{@task.id}" }
    assert_not_nil idx, "completed task should be present in the task list"
    assert rows[idx].has_css?('div.completed'), "expected the task row to show completed"

    # All rows before this index should be incomplete (no child 'div.completed')
    before = rows[0...idx] || []
    assert before.all? { |r| !r.has_css?('div.completed') },
      "expected all rows before the completed task to be incomplete"

    # Rows after this index should be completed (they belong to the completed section)
    after = rows[(idx + 1)..-1] || []
    assert after.all? { |r| r.has_css?('div.completed') },
      "expected all rows after the completed task to be completed"
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
    visit tasks_url
    click_on "edit_task_#{@task.id}"
    fill_in "task_name",	with: "Edited Task"
    click_on "Update Task"
    within "div#task_#{@task.id}" do
      assert_text "Edited Task"
    end
  end
end
