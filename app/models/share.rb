class Share < ActiveRecord::Base
  
  named_scope :shared_to_groups, lambda {|group_ids|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group'}
    }
  }
  
  named_scope :shared_to_groups_of_type, lambda {|group_ids, type|{
      :conditions => {:shared_to_id => group_ids, :shared_to_type => 'Group', :shareable_type => type}
    }
  }
  
  def published?
    if shareable.is_a? Assignment
      return shareable.post.published?
      else return true
    end
  end
end