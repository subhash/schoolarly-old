class AddRecurrenceUntilToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :recurrence, :string
    add_column :events, :until, :date
  end

  def self.down
    remove_column :events, :recurrence
    remove_column :events, :until
  end
end
