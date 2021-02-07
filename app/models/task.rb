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

  default_scope { order(created_at: :desc)}

  private

    def set_completed_at
      self.completed_at = completed ? Time.zone.now : nil
    end

end
