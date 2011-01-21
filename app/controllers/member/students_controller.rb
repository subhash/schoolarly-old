class Member::StudentsController < ApplicationController
  
  before_filter :find_group
  
  require "csv"
  
  def create
    @users = []
    @failed_students = []
    CSV.parse(params[:students]) do |row|
      user = User.new(:email => row[1].strip)
      user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
      name = row[0].split(' ',2)
      user.profile = Profile.new(:first_name => name[0],:last_name => name[1])
      user.person = Student.new      
      if user.invite_over_email
        # TODO check if you are allowed to invite
        @group.invite_and_accept(user)
        GroupMailer.deliver_entry_notification(@group, current_user, user)  
      else
        @failed_students << row.join(",")
      end
      @users << user
    end
    if @failed_students.blank?
      flash[:ok] = I18n.t("groups.site.Student.invited", :count => @users.count)      
      redirect_back_or_default(Tog::Config["plugins.tog_user.default_redirect_on_login"])
    else    
      @failed_students = @failed_students.join("\n")
      render :action => 'new'
    end
  end
  
  
  private
  def find_group
    @group = Group.find(params[:group_id])
  end 
end