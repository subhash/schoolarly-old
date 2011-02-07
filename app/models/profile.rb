class Profile < ActiveRecord::Base
  
  named_scope :for_group_for_type, lambda{ |group, type|
    {
        :joins      => {:user, :memberships},
        :conditions => {:memberships => {:group_id => group.id},:users => {:person_type => type}}
    }
  }
  
end
