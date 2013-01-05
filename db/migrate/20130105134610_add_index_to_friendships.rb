class AddIndexToFriendships < ActiveRecord::Migration
  def self.up
    add_index :friendships, :inviter_id
    add_index :friendships, :invited_id    
  end

  def self.down
    remove_index :friendships, :inviter_id
    remove_index :friendships, :invited_id    
  end
end
