class CreateWeightedAssignments < ActiveRecord::Migration
  def self.up
    create_table :weighted_assignments do |t|
      t.integer :assignment_id
      t.integer :aggregation_id
      t.decimal :weightage, :precision => 5, :scale => 2
     
      t.timestamps
      
      t.foreign_key :assignment_id, :assignments, :id
      t.foreign_key :aggregation_id, :aggregations, :id
    end
  end

  def self.down
    drop_table :weighted_assignments
  end
end
