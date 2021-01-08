class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.boolean :completed, default: false
      t.datetime :completed_at, default: nil
      t.references :user

      t.timestamps
    end
  end
end
