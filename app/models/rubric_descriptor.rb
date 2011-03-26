class RubricDescriptor < ActiveRecord::Base
  
  belongs_to :criterion
  belongs_to :level
  
end
