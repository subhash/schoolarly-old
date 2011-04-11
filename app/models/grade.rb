class Grade < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assignment
  
  has_many :grade_rubric_descriptors
  has_many :rubric_descriptors, :through => :grade_rubric_descriptors
  
end
