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

  def complete
    self.completed_at = Time.now
    self.completed = true
  end

  def uncomplete
    self.completed_at = nil
    self.completed = false
  end

end
