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

end
