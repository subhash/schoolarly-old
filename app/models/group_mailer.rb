class GroupMailer < ActionMailer::Base
  
  def entry_notification(group, moderator, user)
    setup(group, moderator, user)
    @subject    += "Entry into #{group.name}"
    @content_type = "text/html"
    @body[:group_url]  = group_url(group)
    @body[:group] = group  
    @body[:moderator] = moderator
  end
  
  def exit_notification(group, moderator, user)
    setup(group, moderator, user)
    @subject    += "Removed from #{group.name}"
    @content_type = "text/html"
    @body[:group_url]  = group_url(group)
    @body[:group] = group  
    @body[:moderator] = moderator
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
  end
  
end
