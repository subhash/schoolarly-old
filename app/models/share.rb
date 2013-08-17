class Share < ActiveRecord::Base
  
  belongs_to :shareable, :polymorphic => true, :include => { :user => {:profile => []}} 
  
  named_scope :shared_to_groups, lambda {|group_ids|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group'}
    }
  }
  
  #  named_scope :to_groups_and_users, lambda {|group_ids, user_ids|{
  #      :conditions => ["(shared_to_id IN (?) and shared_to_type = 'Group') OR (shared_to_id IN (?) AND shared_to_type= 'User') ", group_ids, user_ids]
  #    }
  #  }
  
  #  named_scope :to_groups_and_users, lambda {|group_ids, user_ids|{
  #      :conditions => ["(shared_to_id IN (?) and shared_to_type = 'Group') OR (shared_to_id IN (?) AND shared_to_type= 'User') ", group_ids, user_ids],
  #      :group => "shareable_type, shareable_id",
  #      :select => "shares.*, max(updated_at) AS updated_at_max",
  #      :order => "updated_at_max DESC"
  #    }
  #  }
  
  
#  named_scope :to_groups_and_users, lambda {|group_ids, user_ids|{
#        :conditions => ["((shared_to_id IN (?) and shared_to_type = 'Group') OR (shared_to_id IN (?) AND shared_to_type= 'User')) AND updated_at >= ALL(select a.updated_at from shares a where a.shareable_id = shares.shareable_id and a.shareable_type = shares.shareable_type)", group_ids, user_ids],
#        :order => "updated_at DESC"
#    }
#  }
  
  named_scope :to_groups_and_users, lambda {|group_ids, user_ids|{
        :conditions => ["((shared_to_id IN (?) and shared_to_type = 'Group') OR (shared_to_id IN (?) AND shared_to_type= 'User'))", group_ids, user_ids],
        :order => "updated_at DESC",
        :include => {:shareable => [], :shared_to =>[:parent], :user => {:profile => []}}
    }
  }
  
  named_scope :to_groups_and_users_of_type, lambda {|group_ids, user_ids, type|{
      :conditions => ["((shared_to_id IN (?) and shared_to_type = 'Group' and shareable_type = ? ) OR (shared_to_id IN (?) AND shared_to_type= 'User' and shareable_type = ? )) AND updated_at >= ALL(select a.updated_at from shares a where a.shareable_id = shares.shareable_id and a.shareable_type = shares.shareable_type)", group_ids, type, user_ids, type]
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
  
  def published?
    if shareable.is_a? Assignment or shareable.is_a? Submission
      return shareable.post.published?
    elsif shareable.is_a? Post
      return shareable.published?
    else return true
    end
  end
  
  def Share.latest
    now = Time.zone.now
    shares = Share.between now - 1.day, now
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