class Member::StudentsController < ApplicationController
  
  require "csv"
  
  def new
    @school = School.find(params[:school_id])
  end
  
  def create
    @school = School.find(params[:school_id])
    CSV.parse(params[:students]) do |row|
      @user = User.new(:email => row[1])
      @user.login ||= @user.email if Tog::Config["plugins.tog_user.email_as_login"]
      name = row[0].split(' ',2)
      @user.profile = Profile.new(:first_name => name[0],:last_name => name[1])
      @user.person = Student.new
      @user.invite_over_email 
      
      # TODO check if you are allowed to invite
      @school.group.invite_and_accept(@user)
    end
    redirect_back_or_default(Tog::Config["plugins.tog_user.default_redirect_on_signup"])
    flash[:notice] = I18n.t("tog_user.user.sign_up")
  end
  
  
end