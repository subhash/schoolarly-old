class UserMailer < ActionMailer::Base

  def invite_notification(user)
    setup_email(user)
    @subject     = (@subject || "") + I18n.t("tog_user.mailer.reset_password")
    @body[:url]  = reset_url(user.password_reset_code)
  end

end
