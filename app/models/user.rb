class User < ActiveRecord::Base
  
  belongs_to :person, :polymorphic => true
  
  named_scope :of_type, lambda { |type| {:conditions => {:person_type => type}}}
  
  has_many :attachments
  has_many :rubrics
  
  
  has_many :sharings, :class_name => 'Share', :dependent => :destroy, :as => :shared_to, :order => "updated_at desc" do
    def of_type(type)
      find :all, :conditions => {:shareable_type => type}
    end
  end
  
  #  has_many :groups, :through => :memberships,
  #                    :conditions => "memberships.state='active' and groups.state='active'",
  #                    :order => "groups.updated_at"
  
  def student?
    person.is_a? Student
  end
  
  def parent?
    person.is_a? Parent
  end
  
  def school
    groups.school.first.network unless groups.school.blank?
  end
  
  def password_required?
    password_reset_code.blank? && (crypted_password.blank? || !password.blank?)
  end
  
  def invite_over_email
    @invited_over_email = true
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(true)
  end
  
  def recently_invited_over_email?
    @invited_over_email
  end
  
  after_save :send_invitation_over_email
  
  #  after_save :create_default_blog
  
  def send_invitation_over_email
    UserMailer.deliver_invite_notification(self) if self.recently_invited_over_email?
  end
  
  def type
    person_type ? person_type.downcase.pluralize : 'members'
  end
  
  def friend_users
    profile.friends.map(&:user)
  end
  
  #  def create_default_blog
  #    if self.recently_activated?      
  #      blog_name = "#{self.profile.full_name}'s blog"
  #      blog_description = "Default blog for #{self.profile.full_name}"
  #      unless self.bloggerships.find_by_rol("default")
  #        bs = self.bloggerships.new
  #        bs.rol = "default"
  #        bs.build_blog(:title => blog_name, :description => blog_description, :author => self)
  #        bs.save
  #      end
  #    end
  #  end
  
  #  def default_blog
  #    self.bloggerships.find_by_rol("default").blog
  #  end
  
  
end
