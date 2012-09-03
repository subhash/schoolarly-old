class Admin::MessagesController < Admin::BaseController

  if Rails::VERSION::STRING >= '2.2'
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
    include ActionView::Helpers::SanitizeHelper
  else
    include ActionView::Helpers::SanitizeHelper
  end

  def show
    @message = Message.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { render :xml => @message }
    end
  end

  def index   
    @messages = Message.all_inbox.paginate :page => params[:page]

    respond_to do |format|
      format.html
      format.rss { render :rss => @messages }
    end
  end

  def destroy
    message = Message.find(params[:id])
    message.destroy
    redirect_to :action => 'index'
  end

end