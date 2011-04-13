class Grade < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assignment
  
  has_many :grade_rubric_descriptors, :dependent => :destroy
  has_many :rubric_descriptors, :through => :grade_rubric_descriptors
  
  
  def grade_points
    rubric_descriptors.collect(&:points).sum
  end
  
end
