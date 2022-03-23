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
  belongs_to :user

  validates :name, presence: true

  before_save :set_completed_at if :completed_changed?

  scope :todo, -> { where(completed: false).order(created_at: :desc)}
  scope :done, -> { where(completed: true).order(completed_at: :desc)}
  # scope :all_tasks, -> { todo + done }
  scope :all_tasks, -> { order(:completed, completed_at: :desc, created_at: :desc)}

  # Time in days from created to completed
  def time_to_complete
    completed ? ((Time.zone.now - completed_at) / 84600.0) : nil
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
