class Member::MessagesController < Member::BaseController
  
  def create
    begin
      to_users = User.active.find(params[:message][:to_user_id].split(','))
    rescue ActiveRecord::RecordNotFound => e
      error = I18n.t("tog_mail.member.user_not_found")
    end
    if to_users.blank?
      error = I18n.t("tog_mail.member.user_not_found")
    end
    for to_user in to_users do 
      @message = Message.new(
      :from => current_user,
      :to => to_user,
      :subject => sanitize(params[:message][:subject]),
      :content => sanitize(params[:message][:content])
      )
      begin
        @message.dispatch!
      rescue Exception => e
        error = e
        break
      end
    end
    respond_to do |format|
      unless error
        flash[:ok] = I18n.t("tog_mail.member.message_sent")
        format.html { redirect_to member_messages_path }
        format.xml { render :xml => @message, :status => :created, :location => member_message_path(:id => @message) }
      else
        flash[:error] = error 
        @from = current_user
        format.html { render :action => "new" }
        format.xml { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end