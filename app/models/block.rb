class Block < ActiveRecord::Base
  
  has_one :group, :as => :network
  
end
