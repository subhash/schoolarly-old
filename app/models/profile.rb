class Profile < ActiveRecord::Base
  
  named_scope :for_group_for_type, lambda{ |group, type|
    {
        :joins      => {:user, :memberships},
        :conditions => {:memberships => {:group_id => group.id},:users => {:person_type => type}}
    }
  }
  
  def set_default_icon
    unless self.icon?
      if FileTest.exist?(RAILS_ROOT + "/public/images/#{full_name}.jpg")
        self.icon = File.new(RAILS_ROOT + "/public/images/#{full_name}.jpg")
      elsif Tog::Config["plugins.tog_social.profile.image.default"]
        default_profile_icon = File.join(RAILS_ROOT, 'public', 'tog_social', 'images', Tog::Config["plugins.tog_social.profile.image.default"])
        self.icon = File.new(default_profile_icon)
      end
    end
  end
  
  
end
