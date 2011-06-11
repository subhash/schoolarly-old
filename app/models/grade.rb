class Grade < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assignment
  
  has_many :grade_rubric_descriptors, :dependent => :destroy
  has_many :rubric_descriptors, :through => :grade_rubric_descriptors
  
  
  def grade_points
    Rubric.trim(rubric_descriptors.collect(&:points).sum)
  end
  
  def rubric_points
    assignment.rubric.grade_type ?  rubric_descriptors.first.level.name : "#{grade_points}/#{assignment.rubric.max_points}"
  end
  
  def score
    Rubric.trim(self[:score])
  end
  
end
