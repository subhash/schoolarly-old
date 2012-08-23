class UserMailer < ActionMailer::Base
  
  def signup_invitation_notification(user, inviter)
    setup_email(user)
    @from                   = "#{inviter.name} <#{inviter.email}>"
    @subject                += "Invitation from Global Public School - Welcome to Schoolarly Network" 
    @body[:url]             = reset_url(user.password_reset_code)
    @body[:inviter]         = inviter
  end


end
