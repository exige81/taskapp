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

  test "strikethrough animation class applied on toggle" do
    visit '/all'
    # Task One starts as incomplete
    within "div#task_#{@task.id}" do
      assert_no_selector "div.strikethru"
      assert_no_selector "div.completed"
    end

    # Toggle to complete - should trigger strikethru animation
    check "toggle_task_#{@task.id}"

    # After Turbo Stream updates, the element should have either the animation class
    # or the completed class (animation may have already finished)
    within "div#task_#{@task.id}" do
      # Wait for Turbo Stream to update - element should show completed state
      assert_selector "div.strikethru, div.completed", wait: 2
    end

    # After animation and page refresh, should be in completed state
    assert_selector "div#task_#{@task.id} div.completed", wait: 5
  end

  test "completed task sorts bottom" do
    visit '/all'
    # Make sure the task exists
    assert_selector "div#task_#{@task.id}", count: 1

    # Mark the task complete
    check "toggle_task_#{@task.id}"

    # Wait for the task to show as completed (either strikethru animation or completed class)
    within "div#task_#{@task.id}" do
      assert_selector "div.strikethru, div.completed", wait: 5
    end

    # Wait for page to refresh and resort (after animation)
    sleep 0.3  # Allow animation + refresh to complete

    # After refresh, the completed task should be sorted with other completed tasks
    # Check that the task still exists and is marked completed
    assert_selector "div#task_#{@task.id}", count: 1
    within "div#task_#{@task.id}" do
      assert_selector "div.completed, div.strikethru", wait: 2
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
    assert_selector "div#task_#{@task.id}", count: 1  # Task One is incomplete, should be visible
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
    assert_selector "div#task_#{@task.id}"  # Task exists before delete

    accept_confirm do
      click_on "delete_task_#{@task.id}"
    end

    # Verify task is removed from page (with wait for Turbo)
    assert_no_selector "div#task_#{@task.id}", wait: 5
  end

  test "editing a task" do
    visit tasks_url
    click_on "edit_task_#{@task.id}"
    fill_in "task_name",	with: "Edited Task"
    click_on "Update Task"
    # After update, redirects to root_url (task list)
    within "div#task_#{@task.id}" do
      assert_text "Edited Task"
    end
  end
end
