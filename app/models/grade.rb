class Grade < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assignment
  
  has_and_belongs_to_many :rubric_descriptors
  
end
