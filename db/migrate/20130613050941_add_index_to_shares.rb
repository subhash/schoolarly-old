class AddIndexToShares < ActiveRecord::Migration
 def self.up
   add_index :shares, :shareable_id
 end

 def self.down
   remove_index :shares, :shareable_id
 end
end