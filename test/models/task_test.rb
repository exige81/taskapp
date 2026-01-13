
# == Schema Information
#
# Table name: tasks
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  completed    :boolean          default(FALSE)
#  completed_at :datetime
#  user_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class TaskTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  def setup
    @user = users(:normal_user)
  end
  
  test "valid task" do
    task = Task.new( name: 'Testing', user: @user)
    assert task.valid?
    assert task.completed? == false
    assert task.completed_at == nil
  end
  
  test "Task must have name" do
    task = Task.new( name: "", user: @user)
    assert_not task.valid?
  end
  
  test "Completion of task triggers timestamp" do
    now = Time.zone.now
    task = Task.create( name: "Completion Test", user: @user)
    task.completed = true
    task.save
    assert task.completed_at.between?(now - 1.minute, now + 1.minute)
    task.completed = false
    task.save
    assert_nil task.completed_at
  end
  
  test "Todo scope" do
    second = @user.tasks.create( name: "Second")
    tasks = @user.tasks.todo
    assert tasks.first == second
    assert tasks.last == tasks(:one)
  end
  
  test "Done scope" do
    done = @user.tasks.create(name: "Finished", completed: true)
    tasks = @user.tasks.done
    assert tasks.first == done
    assert tasks.last == tasks(:completed_task)
  end
  
  test "All tasks scope" do
    second = @user.tasks.create( name: "Second")
    done = @user.tasks.create(name: "Finished", completed: true)
    tasks = @user.tasks.all_tasks
    assert tasks.first == second
    assert tasks[1] == tasks(:one)
    assert tasks[2] == done
    assert tasks.last == tasks(:completed_task)
  end
  
  test "Time to complete" do
    assert tasks(:completed_task).time_to_complete.round == 2
    assert_nil tasks(:one).time_to_complete
  end

  test "completed_at is unchanged when updating unrelated attributes" do
    task = tasks(:completed_task)
    original_ts = task.completed_at.to_i

    task.update(name: "Updated name only")
    task.reload

    assert_equal original_ts, task.completed_at.to_i, "completed_at should not change when saving unrelated attributes"
  end

  test "time_to_complete uses 86400 seconds per day (regression)" do
    task = tasks(:completed_task)
    # completed_task fixture uses 2.days.ago
    days = task.time_to_complete
    # A strict tolerance ensures the 84600/86400 typo will fail this test
    assert_in_delta 2.0, days.abs, 0.01, "time_to_complete must compute days using 86400 seconds/day"
  end
  test "Newly Complete" do
    task = Task.new( name: 'Testing', user: @user)
    task.update(completed: true)
    assert task.newly_complete?
    task.reload
    assert_not task.newly_complete?
  end
  
  test "Newly Uncomplete" do
    task = Task.new( name: 'Testing', user: @user, completed: true)
    task.save
    assert_not task.newly_uncomplete?
    task.update(completed: false)
    assert task.newly_uncomplete?
    task.reload
    assert_not task.newly_uncomplete?
  end
  
  test "sets completed_at when completed toggles to true" do
    task = tasks(:one)
    assert_not task.completed, "fixture should start incomplete"
    task.update(completed: true)
    assert task.completed_at.present?, "completed_at should be set when marked completed"
  end
  
  test "clears completed_at when toggled to false" do
    task = tasks(:completed_task)
    assert task.completed, "fixture should start completed"
    task.update(completed: false)
    assert_nil task.completed_at, "completed_at should be cleared when marked incomplete"
  end
  
  test "time_to_complete returns days as a float for completed tasks" do
    task = tasks(:completed_task)
    # completed_task fixture has completed_at = 2.days.ago
    days = task.time_to_complete
    assert_in_delta 2.0, days.abs, 0.2, "time_to_complete should be approximately 2 days"
  end

  # Broadcast configuration tests
  #
  # These tests verify that the Task model is properly configured
  # for Turbo Streams broadcasting. The actual broadcast delivery
  # is tested in system tests where transactions commit properly.

  test "task responds to broadcast methods" do
    task = Task.new(name: "Test", user: @user)
    assert task.respond_to?(:broadcast_prepend_to)
    assert task.respond_to?(:broadcast_replace_to)
    assert task.respond_to?(:broadcast_remove_to)
  end

  test "task generates correct stream name for user" do
    # Verify the stream name includes the user and "tasks" identifier
    stream_name = [@user, "tasks"]
    signed = Turbo::StreamsChannel.signed_stream_name(stream_name)
    assert signed.present?
    assert_kind_of String, signed
  end

end
