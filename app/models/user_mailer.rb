class UserMailer < ActionMailer::Base

  def invite_notification(user, from = Tog::Config["plugins.tog_core.mail.system_from_address"])
    setup_email(user)
    @from = from
    @subject     = "Welcome to Schoolarly - " + I18n.t("tog_user.mailer.reset_password")
    @body[:url]  = reset_url(user.password_reset_code)
  end

end
