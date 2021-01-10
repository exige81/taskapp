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

  test "Completed task is complete" do
    task = Task.create( name: "complete me", user: @user)
    task.complete
    assert task.completed == true
    assert_not_nil task.completed_at
    assert task.completed?
  end

  test "Completed task can be uncompleted" do
    task = Task.create( name: "uncompleted", user: @user)
    task.complete
    assert task.completed?
    task.uncomplete
    assert_not task.completed?
    assert_nil task.completed_at
  end
end
