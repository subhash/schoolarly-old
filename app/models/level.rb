class Level < ActiveRecord::Base
  
  belongs_to :rubric
  acts_as_list :scope => :rubric
  
  has_many :rubric_descriptors, :dependent => :destroy
  
  validates_presence_of :name
  validates_numericality_of :points, :allow_nil => true
  
  def points
    Rubric.trim(self[:points])
  end
  
end
