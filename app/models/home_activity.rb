class HomeActivity < ActiveRecord::Base 
  
  acts_as_shareable
  
  has_one :assignment, :as => :activity, :dependent => :destroy
  validates_presence_of :due_date
  
  accepts_nested_attributes_for :assignment
  
end
