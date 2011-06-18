class GroupMailer < ActionMailer::Base
  
  def entry_notification(group, moderator, user)
    setup(group, moderator, user)
    @subject    += "Entry into #{group.name}"    
  end
  
  def exit_notification(group, moderator, user)
    setup(group, moderator, user)
    @subject    += "Removed from #{group.name}"
  end
  
  def revoke_moderator_notification(group, moderator, user)
    setup(group, moderator, user)
    @subject    += "You are no longer a moderator of #{group.name}"
  end
  
  def add_moderator_notification(group, moderator, user)
    setup(group, moderator, user)
    @subject    += "You are now a moderator of #{group.name}"
  end
  
  private
  
  def setup(group, moderator, user)
    from = moderator.email
    to = user.email
    @recipients  = "#{to}"
    cc group.moderators.map {|u| "#{u.name} <#{u.email}>"}
    @from        = "#{from}"
    @content_type = "text/html"
    @subject     = Tog::Config["plugins.tog_core.mail.default_subject"]
    @sent_on     = Time.now
    @body[:group_url]  = member_group_url(group)
    @body[:group] = group  
    @body[:moderator] = moderator
  end
  
end
