require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  Capybara.default_max_wait_time = 5

  # System tests drive a real browser, so sign in through the login form.
  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
    assert_selector "a[href='#{session_path}']" # navbar logout link
  end

  def sign_out
    Capybara.reset_sessions!
  end
end
