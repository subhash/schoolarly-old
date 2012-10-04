class AddIndexToUsers < ActiveRecord::Migration
  def self.up
		add_index :users, :person_id
		add_index :users, :person_type
  end

  def self.down
		remove_index :users, :person_type
		remove_index :users, :person_id
  end
end
