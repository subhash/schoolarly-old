class CreateGradeRubricDescriptors < ActiveRecord::Migration
  def self.up   
    create_table :grade_rubric_descriptors do |t|
      t.integer :grade_id
      t.integer :rubric_descriptor_id
      t.timestamps
      
      t.foreign_key :grade_id, :grades, :id
      t.foreign_key :rubric_descriptor_id, :rubric_descriptors, :id
    end
  end

  def self.down    
    drop_table :grade_rubric_descriptors
  end
end
