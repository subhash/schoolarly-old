class Criterion < ActiveRecord::Base
  
  belongs_to :rubric
  has_many :levels, :through => :rubric
end
