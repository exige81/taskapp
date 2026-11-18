class ReplaceDeviseWithRailsAuthentication < ActiveRecord::Migration[8.1]
  def change
    # Devise stored plain bcrypt hashes (no pepper), which is exactly what
    # has_secure_password expects, so existing passwords keep working.
    rename_column :users, :encrypted_password, :password_digest

    # Devise-only columns (recoverable, rememberable, lockable)
    remove_index :users, :reset_password_token, unique: true
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :failed_attempts, :integer, default: 0, null: false
    remove_column :users, :locked_at, :datetime

    # One row per signed-in browser (Rails authentication generator)
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
