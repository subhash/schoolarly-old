class Picto::Photo < ActiveRecord::Base
  
  acts_as_shareable
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  after_create :touch_parent_shares
  
  
  def touch_parent_shares
    if self.changed? and photoset
      for share in photoset.shares
        share.touch
        share.update_notifications
      end
    end
  end 
  
  
end