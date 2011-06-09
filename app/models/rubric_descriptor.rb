class RubricDescriptor < ActiveRecord::Base
  
  belongs_to :criterion
  belongs_to :level
  
  has_one :rubric, :through => :level
  
  acts_as_list :scope => :criterion
  
  has_many :grade_rubric_descriptors  
  has_many :grades, :through => :grade_rubric_descriptors
  
#  validates_presence_of :description
  
  def points
    level.points ? level.points * criterion.weightage/100.00 : nil
  end
  
end
