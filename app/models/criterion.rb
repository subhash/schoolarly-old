class Criterion < ActiveRecord::Base
  
  belongs_to :rubric
  acts_as_list :scope => :rubric
  has_many :levels, :through => :rubric
  
  has_many :rubric_descriptors, :dependent => :destroy do
    def of(level)
      find :first, :conditions => {:level_id => level.id}
    end
  end 
  accepts_nested_attributes_for :rubric_descriptors, :allow_destroy => true
  
  validates_presence_of :name
  validates_numericality_of :weightage, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100, :allow_nil => true
  
end
