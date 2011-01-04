class UpgradeGroups < ActiveRecord::Migration
  def self.up
      add_column :groups, :network_type, :string
      add_column :groups, :network_id, :integer
      add_column :groups, :parent_id, :integer 
  end
  
  def self.down
    remove_column :groups, :network_type
    remove_column :groups, :network_id
    remove_column :groups, :parent_id
  end
end
