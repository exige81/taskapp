require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with a valid session cookie" do
    session = users(:normal_user).sessions.create!
    cookies.signed[:session_id] = session.id

    connect

    assert_equal users(:normal_user), connection.current_user
  end

  test "rejects connection without a session" do
    assert_reject_connection { connect }
  end
end
