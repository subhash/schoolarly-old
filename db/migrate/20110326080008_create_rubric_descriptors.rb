class CreateRubricDescriptors < ActiveRecord::Migration
  def self.up
    create_table :rubric_descriptors do |t|
      t.string :description
      t.integer :criterion_id
      t.integer :level_id
      t.integer :position
      t.timestamps
      
      t.foreign_key :criterion_id, :criteria, :id
      t.foreign_key :level_id, :levels, :id      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :rubric_descriptors
  end
end
