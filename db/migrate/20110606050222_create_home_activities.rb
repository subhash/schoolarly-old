class CreateHomeActivities < ActiveRecord::Migration
  def self.up
    create_table :home_activities do |t|
      
      t.datetime :due_date
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :home_activities
  end
end
