class Grade < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assignment
  
  has_many :grade_rubric_descriptors, :dependent => :destroy
  has_many :rubric_descriptors, :through => :grade_rubric_descriptors
  
  
  def grade_points
    rubric_descriptors.collect(&:points).sum
  end
  
  def max_points
    rubric_descriptors.first.max_points
  end
  
  def total_points
    grade_points/max_points * assignment.score
  end
  
end
