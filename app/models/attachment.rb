class Attachment < ActiveRecord::Base
  
  has_attached_file :doc, {:styles => {
      :big    => Tog::Plugins.settings(:tog_social, "profile.image.versions.big"),
      :medium => Tog::Plugins.settings(:tog_social, "profile.image.versions.medium"),
      :small  => Tog::Plugins.settings(:tog_social, "profile.image.versions.small"),
      :tiny   => Tog::Plugins.settings(:tog_social, "profile.image.versions.tiny")
    }}
    
  belongs_to :user
    
end
