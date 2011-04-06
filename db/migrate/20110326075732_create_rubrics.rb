class CreateRubrics < ActiveRecord::Migration
  def self.up
    create_table :rubrics do |t|
      t.string :title
      t.integer :user_id
      t.timestamps
      
      t.foreign_key :user_id, :users, :id   
    end
  end
  
  def self.down
    drop_table :rubrics
  end
end
