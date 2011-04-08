class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.integer :post_id
      t.integer :rubric_id
      t.datetime :due_date
      t.decimal :score, :precision => 6, :scale => 2
      t.timestamps
      
      t.foreign_key :post_id, :posts, :id
      t.foreign_key :rubric_id, :rubrics, :id   
    end
  end
  
  def self.down
    drop_table :assignments
  end
end
