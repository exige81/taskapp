# Rake tasks for migrating data from PostgreSQL (Heroku) to SQLite.
#
# Usage:
#   1. With Heroku Postgres still connected (before switching to SQLite):
#      RAILS_ENV=development rails db:migrate_from_pg:export
#
#   2. After switching to SQLite (database.yml updated):
#      RAILS_ENV=development rails db:create db:migrate
#      RAILS_ENV=development rails db:migrate_from_pg:import
#
#   3. Verify the migration:
#      RAILS_ENV=development rails db:migrate_from_pg:verify

namespace :db do
  namespace :migrate_from_pg do
    desc "Export PostgreSQL data to JSON files (run BEFORE switching to SQLite)"
    task export: :environment do
      require "json"

      export_dir = Rails.root.join("tmp", "pg_export")
      FileUtils.mkdir_p(export_dir)

      puts "Exporting data from PostgreSQL..."

      # Export users
      users = ActiveRecord::Base.connection.exec_query("SELECT * FROM users ORDER BY id")
      File.write(export_dir.join("users.json"), users.to_a.to_json)
      puts "  Exported #{users.count} users"

      # Export tasks
      tasks = ActiveRecord::Base.connection.exec_query("SELECT * FROM tasks ORDER BY id")
      File.write(export_dir.join("tasks.json"), tasks.to_a.to_json)
      puts "  Exported #{tasks.count} tasks"

      # Export schema_migrations for reference
      migrations = ActiveRecord::Base.connection.exec_query("SELECT * FROM schema_migrations ORDER BY version")
      File.write(export_dir.join("schema_migrations.json"), migrations.to_a.to_json)
      puts "  Exported #{migrations.count} schema migrations"

      puts "\nExport complete! Files saved to #{export_dir}"
      puts "You can now switch to SQLite (update Gemfile + database.yml) and run the import task."
    end

    desc "Import JSON data into SQLite (run AFTER switching to SQLite and running db:migrate)"
    task import: :environment do
      require "json"

      export_dir = Rails.root.join("tmp", "pg_export")

      unless Dir.exist?(export_dir)
        abort "Error: Export directory not found at #{export_dir}.\nRun `rails db:migrate_from_pg:export` first (with PostgreSQL still configured)."
      end

      puts "Importing data into SQLite..."

      ActiveRecord::Base.transaction do
        # Import users (preserving IDs and encrypted_password hashes)
        users_data = JSON.parse(File.read(export_dir.join("users.json")))

        users_data.each do |user|
          columns = %w[id email encrypted_password reset_password_token
                       reset_password_sent_at remember_created_at created_at updated_at]

          values = columns.map { |col|
            val = user[col]
            val.nil? ? "NULL" : ActiveRecord::Base.connection.quote(val)
          }

          ActiveRecord::Base.connection.execute(
            "INSERT INTO users (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
          )
        end
        puts "  Imported #{users_data.count} users"

        # Import tasks (preserving IDs and associations)
        tasks_data = JSON.parse(File.read(export_dir.join("tasks.json")))

        tasks_data.each do |task|
          columns = %w[id name completed completed_at user_id created_at updated_at]

          values = columns.map { |col|
            val = task[col]
            if val.nil?
              "NULL"
            elsif col == "completed"
              # PostgreSQL booleans come as true/false, SQLite uses 1/0
              val ? "1" : "0"
            else
              ActiveRecord::Base.connection.quote(val)
            end
          }

          ActiveRecord::Base.connection.execute(
            "INSERT INTO tasks (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
          )
        end
        puts "  Imported #{tasks_data.count} tasks"

        # Reset SQLite autoincrement sequences
        max_user_id = users_data.map { |u| u["id"] }.max || 0
        max_task_id = tasks_data.map { |t| t["id"] }.max || 0

        if max_user_id > 0
          ActiveRecord::Base.connection.execute(
            "UPDATE sqlite_sequence SET seq = #{max_user_id} WHERE name = 'users'"
          )
        end

        if max_task_id > 0
          ActiveRecord::Base.connection.execute(
            "UPDATE sqlite_sequence SET seq = #{max_task_id} WHERE name = 'tasks'"
          )
        end
        puts "  Reset autoincrement sequences"
      end

      puts "\nImport complete!"
    end

    desc "Verify data integrity after migration"
    task verify: :environment do
      require "json"

      export_dir = Rails.root.join("tmp", "pg_export")

      unless Dir.exist?(export_dir)
        abort "Error: Export directory not found at #{export_dir}."
      end

      users_data = JSON.parse(File.read(export_dir.join("users.json")))
      tasks_data = JSON.parse(File.read(export_dir.join("tasks.json")))

      puts "=" * 50
      puts "Data Integrity Verification Report"
      puts "=" * 50

      # Count checks
      user_count_match = users_data.count == User.count
      task_count_match = tasks_data.count == Task.count

      puts "\nRecord Counts:"
      puts "  Users  - Export: #{users_data.count}, SQLite: #{User.count} #{user_count_match ? '✓' : '✗ MISMATCH'}"
      puts "  Tasks  - Export: #{tasks_data.count}, SQLite: #{Task.count} #{task_count_match ? '✓' : '✗ MISMATCH'}"

      # Verify password hashes are preserved
      puts "\nPassword Hash Verification:"
      password_issues = 0
      users_data.each do |pg_user|
        sqlite_user = User.find_by(id: pg_user["id"])
        if sqlite_user.nil?
          puts "  ✗ User ID #{pg_user['id']} (#{pg_user['email']}) not found in SQLite!"
          password_issues += 1
        elsif sqlite_user.encrypted_password != pg_user["encrypted_password"]
          puts "  ✗ User ID #{pg_user['id']} (#{pg_user['email']}) password hash mismatch!"
          password_issues += 1
        end
      end

      if password_issues == 0
        puts "  ✓ All #{users_data.count} user password hashes preserved correctly"
      else
        puts "  ✗ #{password_issues} password hash issue(s) found!"
      end

      # Verify task associations
      puts "\nTask Association Verification:"
      task_issues = 0
      tasks_data.each do |pg_task|
        sqlite_task = Task.find_by(id: pg_task["id"])
        if sqlite_task.nil?
          puts "  ✗ Task ID #{pg_task['id']} not found in SQLite!"
          task_issues += 1
        elsif sqlite_task.user_id != pg_task["user_id"]
          puts "  ✗ Task ID #{pg_task['id']} user_id mismatch (expected #{pg_task['user_id']}, got #{sqlite_task.user_id})!"
          task_issues += 1
        end
      end

      if task_issues == 0
        puts "  ✓ All #{tasks_data.count} task associations preserved correctly"
      else
        puts "  ✗ #{task_issues} task association issue(s) found!"
      end

      # Summary
      puts "\n" + "=" * 50
      all_passed = user_count_match && task_count_match && password_issues == 0 && task_issues == 0
      if all_passed
        puts "RESULT: ALL CHECKS PASSED ✓"
        puts "\nUsers can log in with their existing passwords."
      else
        puts "RESULT: SOME CHECKS FAILED ✗"
        puts "\nPlease investigate the issues above before deploying."
      end
      puts "=" * 50
    end
  end
end
