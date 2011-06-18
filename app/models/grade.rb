class Grade < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assignment
  
  has_many :grade_rubric_descriptors, :dependent => :destroy
  has_many :rubric_descriptors, :through => :grade_rubric_descriptors
  
  acts_as_shareable
  
  after_save :touch_shares
  
  def grade_points
    Rubric.trim(rubric_descriptors.collect(&:points).sum)
  end
  
  def rubric_points
    assignment.rubric.grade_type? ?  "Grade: #{rubric_descriptors.first.level.name}" : "#{grade_points}/#{assignment.rubric.max_points}"
  end
  
  def score
    Rubric.trim(self[:score])
  end
  
  def touch_shares
    for share in  assignment.shares
      share.touch
    end
  end 
  
end
