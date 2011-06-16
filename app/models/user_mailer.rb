class UserMailer < ActionMailer::Base
  
  def signup_invitation_notification(user)
    setup_email(user)
    @subject                = "Welcome to Schoolarly - " + I18n.t("tog_user.mailer.reset_password")
    @body[:url]             = reset_url(user.password_reset_code)
  end


end
