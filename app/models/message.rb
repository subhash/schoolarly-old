class Message < ActiveRecord::Base
  acts_as_sanitized
  
  named_scope :all_inbox, :include => :folder, :conditions => {'folders.name' => 'Inbox'}, :order => 'messages.created_at desc'
end
