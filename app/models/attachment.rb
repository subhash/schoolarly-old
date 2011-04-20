class Attachment < ActiveRecord::Base
  acts_as_commentable
  
  has_attached_file :doc, Tog::Plugins.storage_options   
  
  belongs_to :user
  
  acts_as_shareable
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
end