class Submission < ActiveRecord::Base
  
  belongs_to :assignment
  belongs_to :post
  
  accepts_nested_attributes_for :post
  
end
