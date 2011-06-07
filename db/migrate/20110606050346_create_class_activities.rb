class CreateClassActivities < ActiveRecord::Migration
  def self.up
    create_table :class_activities do |t|
      t.date :date
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :class_activities
  end
end
