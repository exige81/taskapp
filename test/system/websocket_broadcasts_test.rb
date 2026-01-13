require "application_system_test_case"

class WebsocketBroadcastsTest < ApplicationSystemTestCase
  # WebSocket broadcast tests for real-time updates across browser sessions

  # The model tests in test/models/task_test.rb verify that the broadcast
  # methods are properly configured on the Task model.

  setup do
    @user = users(:normal_user)
    @task = tasks(:one)
  end

  test "WebSocket subscription element is present when signed in" do
    sign_in @user
    visit root_url
    # Verify the turbo_stream_from helper creates the subscription element
    assert_selector "turbo-cable-stream-source", visible: :all
  end

  test "WebSocket subscription is not present when signed out" do
    visit root_url
    # Verify no subscription when not logged in
    assert_no_selector "turbo-cable-stream-source", visible: :all
  end

  test "task created in one session appears in another via broadcast" do

    Capybara.using_session(:browser_one) do
      sign_in @user
      visit root_url
      assert_selector "turbo-cable-stream-source", visible: :all
    end

    Capybara.using_session(:browser_two) do
      sign_in @user
      visit root_url
      fill_in "Name", with: "Broadcast test task"
      click_on "Add Task"
      assert_selector "div", text: "Broadcast test task"
    end

    Capybara.using_session(:browser_one) do
      assert_selector "div", text: "Broadcast test task", wait: 10
    end
  end

  test "task toggle in one session updates another via broadcast" do

    Capybara.using_session(:browser_one) do
      sign_in @user
      visit "/all"
      assert_selector "div#task_#{@task.id}"
    end

    Capybara.using_session(:browser_two) do
      sign_in @user
      visit "/all"
      check "toggle_task_#{@task.id}"
      within "div#task_#{@task.id}" do
        assert_selector "div.strikethru, div.completed", wait: 5
      end
    end

    Capybara.using_session(:browser_one) do
      within "div#task_#{@task.id}" do
        assert_selector "div.strikethru, div.completed", wait: 10
      end
    end
  end

  test "task deleted in one session is removed from another via broadcast" do

    Capybara.using_session(:browser_one) do
      sign_in @user
      visit root_url
      assert_selector "div#task_#{@task.id}"
    end

    Capybara.using_session(:browser_two) do
      sign_in @user
      visit root_url
      accept_confirm do
        click_on "delete_task_#{@task.id}"
      end
      assert_no_selector "div#task_#{@task.id}", wait: 5
    end

    Capybara.using_session(:browser_one) do
      assert_no_selector "div#task_#{@task.id}", wait: 10
    end
  end
end
