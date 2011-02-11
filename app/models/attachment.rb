class Attachment < ActiveRecord::Base
  acts_as_commentable
  has_attached_file :doc
  
  belongs_to :user
  
end
