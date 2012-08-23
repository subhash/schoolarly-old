class UserMailer < ActionMailer::Base
  
  def signup_invitation_notification(user, inviter)
    setup_email(user)
    @from                   = "#{inviter.name} <#{inviter.email}>"
    @subject                += user.school ? "Invitation from #{user.school} - Welcome to Schoolarly Network" : "Welcome to Schoolarly Network"
    @body[:url]             = reset_url(user.password_reset_code)
    @body[:inviter]         = inviter.school ? "IT team @ #{inviter.school}" : inviter.name
    @body[:school]          = inviter.school ? inviter.school : "Schoolarly team"
    @body[:parent_text]     = inviter.parent? ? "Be in touch with your child's school activities!" : ""
    @body[:address]         = inviter.parent? ? "Dear Parent/Guardian" : "Hi"
  end
  
  
end
