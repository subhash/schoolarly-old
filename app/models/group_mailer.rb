class GroupMailer < ActionMailer::Base

  def invitation(group, moderator, user)
      setup_email(moderator.email, user.email)
      @subject    += " Invitation for joining group #{group.name}"
      @content_type = "text/html"
      @body[:group_url]  = group_url(group)
      @body[:accept_url]  = accept_invitation_group_url(group)
      @body[:reject_url]  = reject_invitation_group_url(group)
      @body[:group] = group         
  end
  
  def entry_notification(group, moderator, user)
      setup_email(moderator.email, user.email)
      @subject    += "Entry into #{group.name}"
      @content_type = "text/html"
      @body[:group_url]  = group_url(group)
      @body[:group] = group  
      @body[:moderator] = moderator
  end
  
  def exit_notification(group, moderator, user)
      setup_email(moderator.email, user.email)
      @subject    += "Exit from #{group.name}"
      @content_type = "text/html"
      @body[:group_url]  = group_url(group)
      @body[:group] = group  
      @body[:moderator] = moderator
  end
  
end
