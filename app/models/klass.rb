class Klass < ActiveRecord::Base
  
  has_one :group, :as => :network
  
end
