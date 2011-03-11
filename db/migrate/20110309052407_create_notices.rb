class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.text :content
      t.integer :user_id
      t.timestamps
      
      t.foreign_key :user_id, :users, :id
    end
  end

  def self.down
    drop_table :notices
  end
end
