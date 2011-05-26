class Profile < ActiveRecord::Base
  
  has_dynamic_attributes
  
  DYNAMIC_ATTRIBUTES = YAML.load_file("#{RAILS_ROOT}/config/attributes/attributes.yml")
  
  before_create :initialize_dynamic_attributes
  
  named_scope :for_group_for_type, lambda{ |group, type|
    {
        :joins      => {:user, :memberships},
        :conditions => {:memberships => {:group_id => group.id},:users => {:person_type => type}}
    }
  }
  
  def attributes_list
    attributes_hash.collect {|k,v| config[k].keys}.flatten
  end
  
  def attributes_hash
    attr = DYNAMIC_ATTRIBUTES
    file = "#{RAILS_ROOT}/config/attributes/#{user.school.form_code}.yml"
    if FileTest.exist?(file)
      attr.deep_merge!(YAML.load_file(file))
    end
    attr[user.type]
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
  
  private
  
  def initialize_dynamic_attributes
    # To initialize all profiles - Profile::DYNAMIC_ATTRIBUTES.values.flatten.each {|attr| Profile.all.each{|p| p.send("field_#{attr}=", nil); p.save}}
    attributes_list.each {|attr| self.send("field_#{attr}=", nil)}
  end
  
  
end
