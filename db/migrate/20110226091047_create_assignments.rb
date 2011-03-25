class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.integer :post_id
      t.datetime :due_date
      t.timestamps
      
      t.foreign_key :post_id, :posts, :id
    end
  end

  def self.down
    drop_table :assignments
  end
end
