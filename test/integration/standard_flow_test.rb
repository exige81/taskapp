require "test_helper"

class StandardFlowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:normal_user)
    sign_in_as @user
  end

  test "Home page has login link when logged out" do
    sign_out
    get root_path
    assert_response :success
    assert_select "a[href=?]", new_session_path
    assert_select "a", text: /sign up/i, count: 0
    assert_select "a[href=?]", session_path, count: 0
  end

  test "Home page has logout when logged in" do
    get root_path
    assert_select "a[href=?]", new_session_path, count: 0
    assert_select "a[href=?]", session_path
  end

  test "Public sign-up and password reset are disabled" do
    sign_out
    get "/users/sign_up"
    assert_response :not_found
    get "/users/password/new"
    assert_response :not_found
    get "/passwords/new"
    assert_response :not_found
  end

  test "Logs in with email and password" do
    sign_out
    post session_path, params: { email: @user.email, password: "password" }
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", session_path
  end

  test "Email is matched case-insensitively" do
    sign_out
    post session_path, params: { email: @user.email.upcase, password: "password" }
    assert_redirected_to root_url
  end

  test "Wrong password is rejected" do
    sign_out
    post session_path, params: { email: @user.email, password: "wrong" }
    assert_redirected_to new_session_path
    assert_equal "Invalid email or password.", flash[:alert]
  end

  test "Password hashed Devise-style (bcrypt cost 12, no pepper) still works" do
    sign_out
    @user.update_column(:password_digest, BCrypt::Password.create("legacy-password", cost: 12))
    post session_path, params: { email: @user.email, password: "legacy-password" }
    assert_redirected_to root_url
  end

  test "Logging out ends the session" do
    assert_difference("Session.count", -1) { delete session_path }
    assert_redirected_to root_path
    get new_task_path
    assert_redirected_to new_session_path
  end

  test "Login is rate limited after 10 attempts" do
    sign_out
    # The test env uses a null cache store, so give rate_limit a real one here.
    store = ActiveSupport::Cache::MemoryStore.new
    null_store = SessionsController.cache_store
    null_store.define_singleton_method(:increment) { |*args, **opts| store.increment(*args, **opts) }

    10.times { post session_path, params: { email: @user.email, password: "wrong" } }
    post session_path, params: { email: @user.email, password: "password" }
    assert_redirected_to new_session_path
    assert_equal "Too many attempts. Try again later.", flash[:alert]
  ensure
    null_store.singleton_class.remove_method(:increment)
  end

  test "Account can be edited with the current password" do
    patch account_path, params: { user: { email: @user.email, password: "newpass123", password_confirmation: "newpass123", password_challenge: "password" } }
    assert_redirected_to root_path
    assert @user.reload.authenticate("newpass123")
  end

  test "Account edit requires the current password" do
    patch account_path, params: { user: { email: "changed@example.com", password_challenge: "wrong" } }
    assert_response :unprocessable_entity
    assert_equal "test@example.com", @user.reload.email

    patch account_path, params: { user: { email: "changed@example.com" } }
    assert_response :unprocessable_entity
    assert_equal "test@example.com", @user.reload.email
  end

  test "Blank new password leaves the password unchanged" do
    patch account_path, params: { user: { email: "changed@example.com", password: "", password_confirmation: "", password_challenge: "password" } }
    assert_redirected_to root_path
    assert_equal "changed@example.com", @user.reload.email
    assert @user.authenticate("password")
  end

  test "Account page requires login" do
    sign_out
    get edit_account_path
    assert_redirected_to new_session_path
  end

  test "Show tasks on user page" do
    get root_path
    assert_select "div#tasklist"
    assert_select "div[id=?]",  "task_#{tasks(:one).id}", count: 1
    assert_select "div.completed", count: 1
    assert_select "a[href=?]", edit_task_path(tasks(:one)), count: 1
    assert_select "a[href=?]", task_path(tasks(:one)), count: 1
  end

  test "New task form on index page" do
    get root_path
    assert_select "input#task_name", count: 1
    assert_select "input[value=?]", "Add Task", count: 1
  end

  test "Completed page should only show completed tasks" do
    get "/completed"
    assert_select "div[id=?]",  "task_#{tasks(:completed_task).id}", count: 1
    assert_select "div[id=?]",  "task_#{tasks(:one).id}", count: 0
  end

  test "All page should only show all tasks" do
    get "/all"
    assert_select "div[id=?]",  "task_#{tasks(:completed_task).id}", count: 1
    assert_select "div[id=?]",  "task_#{tasks(:one).id}", count: 1
  end
end
