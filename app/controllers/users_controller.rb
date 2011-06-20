class UsersController < ApplicationController
  
  before_filter :ban_access, :except => [:reset, :forgot, :new, :create]
  
  def reset
    @user = User.find_by_password_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        @user.reset_password
        @user.register! and @user.activate! if @user.passive?
        self.current_user = @user
        flash[:ok] = I18n.t("tog_user.user.password_updated", :email => @user.email)
        redirect_back_or_default(Tog::Config["plugins.tog_user.default_redirect_on_reset"])
      else
        render :action => :reset
      end
    end
  end
  
end