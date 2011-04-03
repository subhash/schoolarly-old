class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      
      t.string :name
      t.integer :rubric_id
      t.integer :position
      t.decimal :weightage, :precision => 6, :scale => 2
      t.timestamps
      
      t.foreign_key :rubric_id, :rubrics, :id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :levels
  end
end
