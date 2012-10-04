class AddIndexToMembership < ActiveRecord::Migration
  def self.up
		add_index :memberships, :group_id
		add_index :memberships, :user_id
  end

  def self.down
		remove_index :memberships, :user_id
		remove_index :memberships, :group_id
  end
end
