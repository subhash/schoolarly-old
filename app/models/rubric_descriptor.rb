class RubricDescriptor < ActiveRecord::Base
  
  belongs_to :criterion
  belongs_to :level
  
  acts_as_list :scope => :criterion
  
end