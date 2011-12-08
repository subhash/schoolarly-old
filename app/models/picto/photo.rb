class Picto::Photo < ActiveRecord::Base
  
  acts_as_shareable
  
  acts_as_list :scope => [:photoset_id, :user_id]
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  after_create :touch_parent_shares
  
  
  def touch_parent_shares
    if self.changed? and photoset
      for share in photoset.shares
        share.touch
      end
    end
  end 
  
  
end