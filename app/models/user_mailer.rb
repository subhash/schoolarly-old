class UserMailer < ActionMailer::Base
  
  def signup_invitation_notification(user, inviter)
    setup_email(user)
    @from                   = "#{inviter.name} <#{inviter.email}>"
    @subject                += inviter.school ? "Invitation from #{inviter.school.group.name} - Welcome to Schoolarly Network" : "Welcome to Schoolarly Network"
    @body[:url]             = reset_url(user.password_reset_code)
    @body[:inviter]         = inviter.school ? "IT team @ #{inviter.school.group.name}" : inviter.name
    @body[:school]          = inviter.school ? inviter.school.group.name : "Schoolarly team"
    @body[:parent_text]     = user.parent? ? "Be in touch with your child's school activities!" : ""
    @body[:address]         = user.parent? ? "Dear Parent/Guardian" : "Hi"
  end
  
  
end
