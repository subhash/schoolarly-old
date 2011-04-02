class Level < ActiveRecord::Base
  
  belongs_to :rubric
  acts_as_list :scope => :rubric

  has_many :rubric_descriptors, :dependent => :destroy
  
end
