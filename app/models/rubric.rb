class Rubric < ActiveRecord::Base
  
  has_many :criteria
  has_many :levels
  
end
