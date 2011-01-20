class Member::TeachersController < ApplicationController
  
  before_filter :find_group
  
  require "csv"
  
  def create
    @users = []
    @failed_teachers = []
    CSV.parse(params[:teachers]) do |row|
      user = User.new(:email => row[1].strip)
      user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
      name = row[0].split(' ',2)
      user.profile = Profile.new(:first_name => name[0],:last_name => name[1])
      user.person = Teacher.new      
      if user.invite_over_email
        # TODO check if you are allowed to invite
        @group.invite_and_accept(user)
      else
        @failed_teachers << row.join(",")
      end
      @users << user
    end
    if @failed_teachers.blank?
      flash[:ok] = I18n.t("groups.site.invite.invited", :user_count => @users.count)      
      redirect_back_or_default(Tog::Config["plugins.tog_user.default_redirect_on_login"])
    else
      @failed_teachers = @failed_teachers.join("\n")
      render :action => 'new'      
    end
  end
  
  private
  def find_group
     @group = Group.find(params[:group_id])
  end
  
end