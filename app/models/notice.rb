class Notice < ActiveRecord::Base
  acts_as_commentable
  
  acts_as_shareable
  acts_as_sanitized
  
  belongs_to :user
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  def title
    content[0,30]+" .."
  end
  
end
