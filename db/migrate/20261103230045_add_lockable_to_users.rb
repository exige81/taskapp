class AddLockableToUsers < ActiveRecord::Migration[8.1]
  def change
    # Devise :lockable with time-based unlock only (no email), so no unlock_token.
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :locked_at, :datetime
  end
end
