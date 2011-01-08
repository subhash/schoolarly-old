class KlassMailer < GroupMailer
  
  def welcome(group, moderator, user)
      setup_email(moderator.email, user.email)
      @subject    += " Welcome to #{group.network_type} #{group.name}"
      @content_type = "text/html"
      @body[:group] = group
  end
  
end