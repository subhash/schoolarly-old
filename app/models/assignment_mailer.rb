class AssignmentMailer < ActionMailer::Base
  
  def new_assignment_notification(assignment)    
    setup_email(assignment)
    @subject += I18n.t('assignments.mailer.new.subject', :name => assignment.name)
  end
  
  protected
  def setup_email(assignment)
    @recipients = assignment.shareholders.map(&:email).join(",")
    @from         = assignment.user.email
    @subject      = Tog::Config["plugins.tog_core.mail.default_subject"]
    @sent_on      = Time.now
    @content_type = "text/html"
    @body[:assignment] = assignment
  end
  
end
