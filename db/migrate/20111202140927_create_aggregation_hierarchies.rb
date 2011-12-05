class CreateAggregationHierarchies < ActiveRecord::Migration
  def self.up   
    create_table :aggregation_hierarchies, :id => false do |t|
      t.integer  :ancestor_id, :null => false   # ID of the parent/grandparent/great-grandparent/... group
      t.integer  :descendant_id, :null => false # ID of the target group
      t.integer  :generations, :null => false   # Number of generations between the ancestor and the descendant. Parent/child = 1, for example.
    end
    
    # For "all progeny of..." selects:
    add_index :aggregation_hierarchies, [:ancestor_id, :descendant_id], :unique => true
    
    # For "all ancestors of..." selects
    add_index :aggregation_hierarchies, [:descendant_id]    
  end
  
  def self.down
    drop_table :aggregation_hierarchies
  end
end
