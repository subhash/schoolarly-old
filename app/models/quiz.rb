class Quiz < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}

  
end
