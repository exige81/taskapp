module TasksHelper

    def task_state_class(task)
        return "strikethru" if task.newly_complete?
        return "remove-strikethru" if task.newly_uncomplete?
        task.completed? ? "completed" : ""
    end
end
