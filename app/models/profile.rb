class Profile < ActiveRecord::Base
  
  has_dynamic_attributes
  
  DYNAMIC_ATTRIBUTES = {
                        :personal => %w{dob mname fname}, 
                        :contact => %w{alt_email phone add_line1 add_line2 add_line3}, 
                        :health => %w{height weight blood_group vision_l vision_r teeth oral_hygiene specific_ailment}
  }
  
  before_create :initialize_dynamic_attributes
  
  named_scope :for_group_for_type, lambda{ |group, type|
    {
        :joins      => {:user, :memberships},
        :conditions => {:memberships => {:group_id => group.id},:users => {:person_type => type}}
    }
  }
  
  def self.from_wufoo_entry(entry)
    Profile.new(:first_name => entry["Field18"], :last_name => entry["Field19"])
  end
  
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
  
  def form_code
    # sboa-students
    user.school.form_code + "-" + user.type if user.school
  end
  
  private
  
  def initialize_dynamic_attributes
    # To initialize all profiles - Profile::DYNAMIC_ATTRIBUTES.values.flatten.each {|attr| Profile.all.each{|p| p.send("field_#{attr}=", nil); p.save}}
    DYNAMIC_ATTRIBUTES.values.flatten.each {|attr| self.send("field_#{attr}=", nil)}
  end
  
  
end
