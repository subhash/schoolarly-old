class Attachment < ActiveRecord::Base
  
  has_attached_file :doc
    
  belongs_to :user
    
end
