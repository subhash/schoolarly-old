class CommentMailer < ActionMailer::Base
  
  def new_comment_notification(comment, url=nil)
    setup_email(comment, url)
    @recipients = ([comment.commentable_owner] + ShareMailer.shareholders(comment.commentable)).map(&:email).join(",")
    @subject += I18n.t('comments.mailer.new.subject', :commentable => comment.commentable_title)
  end
  
end
