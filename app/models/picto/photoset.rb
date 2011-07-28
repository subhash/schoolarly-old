class Picto::Photoset < ActiveRecord::Base
  
  acts_as_shareable
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}

end