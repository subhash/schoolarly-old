class GroupMailer < ActionMailer::Base

  def invitation(group, moderator, user)
      setup_email(moderator.email, user.email)
      @subject    += " Invitation for joining group #{group.name}"
      @content_type = "text/html"
      @body[:group_url]  = group_url(group)
      mem = group.membership_of(user)
      @body[:accept_url]  = accept_invitation_group_url(group)
      @body[:reject_url]  = reject_invitation_group_url(group)
      @body[:group] = group         
  end    
  
end