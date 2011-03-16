class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.string :doc_file_name
      t.string :doc_content_type
      t.integer :doc_file_size
      t.datetime :doc_updated_at
      t.timestamps
      
      t.foreign_key :user_id, :users, :id
    end
  end

  def self.down
    drop_table :assignments
  end
end
