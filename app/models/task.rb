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
class Task < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user

  normalizes :name, with: -> { _1.strip }

  validates :name, presence: true

  # Set completed_at when the completed flag changes.
  # Use the `if:` option so the callback only runs when `completed` actually changes.
  before_save :set_completed_at, if: :completed_changed?

  # Broadcast changes to all connected clients for real-time updates
  after_create_commit -> { broadcast_prepend_to(user, "tasks", target: "task-items", partial: "tasks/taskrow", locals: { task: self }) }
  after_update_commit -> { broadcast_replace_to(user, "tasks", target: dom_id(self), partial: "tasks/taskrow", locals: { task: self }) }
  after_destroy_commit -> { broadcast_remove_to(user, "tasks", target: dom_id(self)) }

  scope :todo, -> { where(completed: false).order(created_at: :desc)}
  scope :done, -> { where(completed: true).order(completed_at: :desc)}
  # scope :all_tasks, -> { todo + done }
  scope :all_tasks, -> { order(:completed, completed_at: :desc, created_at: :desc)}

  # Time in days from created to completed
  def time_to_complete
    # Time in days from created to completed. Use 86400 seconds per day.
    completed && completed_at ? ((Time.zone.now - completed_at) / 86_400.0) : nil
  end
  
  def newly_complete?
    completed? && completed_previously_changed? ? true : false
  end

  def newly_uncomplete?
    !completed && completed_previously_changed? ? true : false
  end

  private

    def set_completed_at
      self.completed_at = completed ? Time.zone.now : nil
    end


end
