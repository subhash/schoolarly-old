class CreateCriteria < ActiveRecord::Migration
  def self.up
    create_table :criteria do |t|
      
      t.string :name
      t.integer :rubric_id
      t.integer :position
      t.timestamps
      
      t.foreign_key :rubric_id, :rubrics, :id   
    end
  end
  
  def self.down
    drop_table :criteria
  end
end
