class UpgradeUsers < ActiveRecord::Migration
  def self.up
      add_column :users, :person_type, :string
      add_column :users, :person_id, :integer
  end
  
  def self.down
    remove_column :users, :person_type
    remove_column :users, :person_id
  end
end
