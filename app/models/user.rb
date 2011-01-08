class User < ActiveRecord::Base
  belongs_to :person, :polymorphic => true
  
  named_scope :of_type, lambda { |type| {:conditions => {:person_type => type}}}
  
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
  
  def send_invitation_over_email
    UserMailer.deliver_invite_notification(self) if self.recently_invited_over_email?
  end
  
end