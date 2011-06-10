class Submission < ActiveRecord::Base
  
  belongs_to :assignment
  belongs_to :post
  
  belongs_to :user
  
  accepts_nested_attributes_for :post
  
  
end
