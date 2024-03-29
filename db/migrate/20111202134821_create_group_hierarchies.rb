class CreateGroupHierarchies < ActiveRecord::Migration
  def self.up   
    create_table :group_hierarchies do |t|
      t.integer  :ancestor_id, :null => false   # ID of the parent/grandparent/great-grandparent/... group
      t.integer  :descendant_id, :null => false # ID of the target group
      t.integer  :generations, :null => false   # Number of generations between the ancestor and the descendant. Parent/child = 1, for example.
    end
    
#    execute "ALTER TABLE group_hierarchies ADD PRIMARY KEY (ancestor_id, descendant_id);"
    
    # For "all progeny of..." selects:
    add_index :group_hierarchies, [:ancestor_id, :descendant_id], :unique => true
    
    # For "all ancestors of..." selects
    add_index :group_hierarchies, [:descendant_id]  
  end
  
  
  
  def self.down
    drop_table :group_hierarchies
  end
end
