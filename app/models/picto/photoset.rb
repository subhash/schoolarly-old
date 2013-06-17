class Picto::Photoset < ActiveRecord::Base
  
  acts_as_shareable
  acts_as_commentable  # added as dummy entry to make eager loading of comments possible in dashboard
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}, :include => {:shared_to => [:parent] }

end