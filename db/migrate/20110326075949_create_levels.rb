class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      
      t.string :name
      t.integer :rubric_id
      t.timestamps
      
      t.foreign_key :rubric_id, :rubrics, :id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :levels
  end
end
