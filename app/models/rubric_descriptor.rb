class RubricDescriptor < ActiveRecord::Base
  
  belongs_to :criterion
  belongs_to :level
  
  acts_as_list :scope => :criterion
  
  validates_presence_of :description
  
  def points
    level.points * criterion.weightage
  end
  
end
