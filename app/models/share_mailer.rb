class ShareMailer < ActionMailer::Base
  helper :share_mailer
  
  def summary_notification(user, shares)
    recipients "#{user.name} <#{user.email}>"
    from Tog::Config["plugins.tog_core.mail.system_from_address"]
    subject "#{Tog::Config["plugins.tog_core.mail.default_subject"]} Summary - #{Date.today}"
    body :user => user, :shares => shares
  end
  
  def ShareMailer.notify?(share)
    !((share.shareable.is_a? Rubric) || (share.shareable.is_a? Aggregation))    
  end
  
  def ShareMailer.shareholders(shareable)    
    shareable.shares.inject([]) do |c, s|
      c += s.shared_to.users if s.shared_to.is_a?(Group)  
      c << s.shared_to if s.shared_to.is_a?(User)
      c += c.inject([]) {|a, u| a + u.friend_users}
    end
  end
  
end
