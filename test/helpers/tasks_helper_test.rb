require 'test_helper'

class TasksHelperTest < ActionView::TestCase

    def setup
        @completed = tasks(:completed_task)
        @incomplete = tasks(:one)
    end
    
    test "Task State" do
        assert_equal "completed", task_state_class(@completed) 
        assert_equal "", task_state_class(@incomplete)
        @incomplete.update(completed: true)
        assert_equal "strikethru", task_state_class(@incomplete)
        @completed.update(completed: false)
        assert_equal "remove-strikethru", task_state_class(@completed)
    end
end