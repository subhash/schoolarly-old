class Share < ActiveRecord::Base
  
  named_scope :shared_to_groups, lambda {|group_ids|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group'}
    }
  }
  
  named_scope :to_groups_and_users, lambda {|group_ids, user_ids|{
      :conditions => ["(shared_to_id IN (?) and shared_to_type = 'Group') OR (shared_to_id IN (?) AND shared_to_type= 'User') ", group_ids, user_ids]
    }
  }
  
  named_scope :to_groups_and_users_of_type, lambda {|group_ids, user_ids, type|{
      :conditions => ["(shared_to_id IN (?) and shared_to_type = 'Group' and shareable_type = ? ) OR (shared_to_id IN (?) AND shared_to_type= 'User' and shareable_type = ? ) ", group_ids, type, user_ids, type]
    }
  }
  
  
  named_scope :shared_to_groups_of_type, lambda {|group_ids, type|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group', :shareable_type => type}
    }
  }
  
  named_scope :between, lambda { |from, to| {
     :conditions => ["(updated_at >= ? and updated_at <= ?)", from, to]
    }
  }
  
  after_create :create_notifications
  
  
  def published?
    if shareable.is_a? Assignment or shareable.is_a? Submission
      return shareable.post.published?
    elsif shareable.is_a? Post
      return shareable.published?
    else return true
    end
  end
  
  def create_notifications
    ShareMailer.deliver_new_share_notification(self) if ShareMailer.notify?(self) and self.published?
  end
  
  def update_notifications
    ShareMailer.deliver_share_change_notification(self) if ShareMailer.notify?(self) and self.published?
  end
  
  def Share.latest
    # Issues with timezones
    shares = Share.between Time.now - 1.day, Time.now
    shares.inject({}) do |h, share|
      users = []
      shared_to = share.shared_to
      users << shared_to if shared_to.is_a? User
      users += shared_to.users if shared_to.is_a? Group
      users.each {|u| h[u] ||= []; h[u] << share}
      h
    end  
  end
  
end