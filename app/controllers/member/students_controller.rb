class Member::StudentsController < ApplicationController
  
  def create
    @school = School.find(params[:school_id])
    @user = User.new(:email => params[:email])    
    @user.login ||= @user.email if Tog::Config["plugins.tog_user.email_as_login"]
    @user.profile = Profile.new(:first_name => params[:name])    
    @user.person = Student.new
    @user.invite_over_email 
    # TODO check if you are allowed to invite
    @school.group.invite_and_accept(@user)
    redirect_back_or_default(Tog::Config["plugins.tog_user.default_redirect_on_signup"])
    flash[:notice] = I18n.t("tog_user.user.sign_up")
  end
  
  
end