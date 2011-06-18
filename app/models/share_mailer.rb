class ShareMailer < ActionMailer::Base
  
  def new_share_notification(share)    
    setup_email(share)
    @subject += I18n.t("shares.mailer.new.#{share.shareable_type}.subject", :shareable => @body[:shareable_name], :shared_to => @body[:shared_to_name])
  end
  
  protected
  def setup_email(share)
    @body[:share] = share
    @body[:shared_to_name] = name_or_title(share.shared_to)
    @body[:shareable_name] = name_or_title(share.shareable)
    @body[:user_name] = user_or_owner(share.shareable).name
    @from         = user_or_owner(share.shareable).email
    if(share.shareable.respond_to? :shareholders)
      @recipients = share.shareable.shareholders.map(&:email).join(",")
    else
      @recipients = @from
    end    
    @subject      = Tog::Config["plugins.tog_core.mail.default_subject"]
    @sent_on      = Time.now
    @content_type = "text/html"
  end
  
  private
  def name_or_title(object)    
    return object.name if object.respond_to? :name
    return object.title if object.respond_to? :title
  end
  
  def user_or_owner(object)
    return object.user if object.respond_to? :user
    return object.owner if object.respond_to? :owner
  end
  
end
