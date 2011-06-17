class CommentMailer < ActionMailer::Base
  
  def new_comment_notification(comment, url=nil)
    # TODO Remove comment originator from TO list
    setup_email(comment, url)
    if comment.commentable.respond_to? :shareholders
      @recipients = comment.commentable.shareholders.map(&:email).join(",")
    end
    @subject += I18n.t('comments.mailer.new.subject', :commentable => comment.commentable_title)
  end
  
end
