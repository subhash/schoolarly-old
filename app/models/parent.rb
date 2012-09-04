class Parent < ActiveRecord::Base
  
  has_one :user, :as => :person
  
  
  def school_groups
    user.friend_users.collect{|u|u.groups.base.school}.flatten
  end
  
end
