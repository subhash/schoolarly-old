class Criterion < ActiveRecord::Base
  
  belongs_to :rubric
  acts_as_list :scope => :rubric
  has_many :levels, :through => :rubric
  
  has_many :rubric_descriptors, :dependent => :destroy do
    def of(level)
      find :first, :conditions => {:level_id => level.id}
    end
  end 
  accepts_nested_attributes_for :rubric_descriptors
  
  validates_presence_of :name, :weightage
  validates_numericality_of :weightage
  
end
