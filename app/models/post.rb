# == Schema Information
# Schema version: 1
#
# Table name: blogs
#
#  id         :integer(11)   not null, primary key
#  blog_id    :integer(11)
#  title      :string(255)
#  body       :text
#  user_id    :integer(11)
#  created_at :datetime
#  updated_at :datetime
#

class Post < ActiveRecord::Base
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  has_attached_file :doc, Tog::Plugins.storage_options   
  
  validates_presence_of :body, :unless => Proc.new{|p| p.doc.file?}
  
  validates_attachment_presence :doc, :if => Proc.new{|p| p.body.blank?}

end
