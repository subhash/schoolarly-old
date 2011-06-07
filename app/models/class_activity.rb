class ClassActivity < ActiveRecord::Base
  
  has_one :assignment, :as => :activity, :dependent => :destroy

  validates_presence_of :date, :start_time, :end_time
  
  accepts_nested_attributes_for :assignment
  
end
