class User < ActiveRecord::Base
  belongs_to :person, :polymorphic => true
  
  def invite_over_email
    @invited_over_email = true
    self.make_password_reset_code
  end
  
  def recently_invited_over_email?
    @invited_over_email
  end
  
  after_save :send_invitation_over_email
  
  def send_invitation_over_email
    UserMailer.deliver_invite_notification(self) if self.recently_invited_over_email?
  end
  
end