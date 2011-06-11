class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.integer :post_id
      t.integer :assignment_id
      t.integer :user_id
      t.timestamps
      
      t.foreign_key :post_id, :posts, :id
      t.foreign_key :user_id, :users, :id
      t.foreign_key :assignment_id, :assignments, :id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :submissions
  end
end
