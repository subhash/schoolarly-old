class Member::TeachersController < ApplicationController
  
  before_filter :find_school
  
  require "csv"
  
  def create
    @users = []
    @failed_teachers = []
    CSV.parse(params[:teachers]) do |row|
      user = User.new(:email => row[1].strip)
      user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
      name = row[0].split(' ',2)
      user.profile = Profile.new(:first_name => name[0],:last_name => name[1])
      user.person = Student.new      
      if user.invite_over_email
        # TODO check if you are allowed to invite
        @school.group.invite_and_accept(user)
      else
        @failed_teachers << row.join(",")
      end
      @users << user
    end
    @failed_teachers = @failed_teachers.join("\n")
    render :action => 'new' 
  end
  
  private
  def find_school
     @school = School.find(params[:school_id])
  end
  
end