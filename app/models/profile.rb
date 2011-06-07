class Profile < ActiveRecord::Base
  
  has_dynamic_attributes
  
  DYNAMIC_ATTRIBUTES = YAML.load_file("#{RAILS_ROOT}/config/attributes/attributes.yml")
  
  named_scope :for_group_for_type, lambda{ |group, type|
    {
        :joins      => {:user, :memberships},
        :conditions => {:memberships => {:group_id => group.id},:users => {:person_type => type}}
    }
  }
  
  def attributes_list
    attributes_hash.collect {|k,v| v.keys}.flatten
  end
  
  def attributes_hash
    attr = DYNAMIC_ATTRIBUTES
    file = "#{RAILS_ROOT}/config/attributes/#{user.school.form_code}.yml" if user.school
    if file and FileTest.exist?(file)
      attr.deep_merge!(YAML.load_file(file))
    end
    attr[user.type] || {}
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
  
  def method_missing_with_profile_check(method_id, *args, &block)
    begin
      method_missing_without_profile_check method_id, *args, &block
    rescue NoMethodError => e
      unless method_id.to_s =~ /\=$/
        attr = method_id.to_s
        if attr.starts_with?('field_') and attributes_list.any? {|a| attr == "field_#{a}"}
          return nil
        end
      end
      raise e
    end
  end
 
  alias_method_chain :method_missing, :profile_check
  
end
