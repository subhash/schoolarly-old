class ClassActivity < ActiveRecord::Base
    
  acts_as_shareable
  
  has_one :assignment, :as => :activity, :dependent => :destroy
  
end
