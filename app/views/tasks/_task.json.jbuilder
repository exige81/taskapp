json.extract! task, :id, :name, :completed, :completed_at, :created_at, :updated_at
json.url task_url(task, format: :json)
