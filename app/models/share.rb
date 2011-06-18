class Share < ActiveRecord::Base
  
  named_scope :shared_to_groups, lambda {|group_ids|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group'}
    }
  }
  
  named_scope :to_groups_and_user, lambda {|group_ids, user_id|{
      :conditions => ["(shared_to_id IN (?) and shared_to_type = 'Group') OR (shared_to_id = ? AND shared_to_type= 'User') ", group_ids, user_id]
    }
  }
  
  named_scope :to_groups_and_user_of_type, lambda {|group_ids, user_id, type|{
      :conditions => ["(shared_to_id IN (?) and shared_to_type = 'Group' and shareable_type = ? ) OR (shared_to_id = ? AND shared_to_type= 'User' and shareable_type = ? ) ", group_ids, type, user_id, type]
    }
  }
  
  
  named_scope :shared_to_groups_of_type, lambda {|group_ids, type|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group', :shareable_type => type}
    }
  }
  
  after_create :send_notifications
  
  after_update :send_notifications
  
  def published?
    if shareable.is_a? Assignment or shareable.is_a? Submission
      return shareable.post.published?
    elsif shareable.is_a? Post
      return shareable.published?
    else return true
    end
  end
  
  private
  
  def send_notifications
    ShareMailer.deliver_new_share_notification(self) if ShareMailer.notify?(self) and self.published?
  end
end