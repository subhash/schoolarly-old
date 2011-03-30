class Notice < ActiveRecord::Base
  acts_as_commentable
  belongs_to :user
  
  has_many :comments, :order => "created_at DESC", :as => :commentable
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  def title
    content
  end
  
end