class UpdateAssignments < ActiveRecord::Migration
  def self.up
    
    add_column :assignments, :weightage, :decimal, :precision => 5, :scale => 2
    add_column :assignments, :aggregation_id, :integer
    add_foreign_key :assignments,  :aggregation_id, :aggregations, :id
  end

  def self.down
    remove_column :assignments, :weightage
    remove_column :assignments, :aggregation_id
  end
end
