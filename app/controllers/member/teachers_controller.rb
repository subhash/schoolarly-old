class Member::TeachersController < Member::BaseController
  
  before_filter :find_group
  
  require "csv"
  
  def create
    @users = []
    @failed_teachers = []
    CSV.parse(params[:teachers]) do |row|
      name = email = nil
      name, email = row
      user = create_user(email, name, Teacher.new)      
      if !user.new_record?
        @group.join(user)      
      elsif user.invite_over_email(current_user)
        # TODO check if you are allowed to invite
        @group.invite_and_accept(user)
        @group.grant_moderator(user) unless params[:moderator].blank?
        #        commenting out entry into group email for now
        #        GroupMailer.deliver_entry_notification(@group, current_user, user)  
      else
        @failed_teachers << row.join(",")
      end
      @users << user
    end
    if @failed_teachers.blank?
      flash[:ok] = I18n.t("groups.site.Teacher.invited", :count => @users.count)    
      redirect_back_or_default(member_group_path(@group))
    else
      @failed_teachers = @failed_teachers.join("\n")
      render :action => 'new'      
    end
  end
  
  private
  def find_group
    @group = Group.find(params[:group_id])
  end
  
  def create_user(email, name, person)
    first = last = nil
    first, last = name.split(' ',2) if name
    email = email.strip if email
    user = User.find_by_email(email) 
    # If user belongs to same school, just add them
    user = User.new(:email => email) unless user # XXX GPS HACK (user && (user.parent? || user.school == @group.school))
    user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
    if user.profile
      user.profile.first_name = first
      user.profile.last_name = last
    else
      user.profile = Profile.new(:first_name => first,:last_name => last)
    end
    user.person = person
    return user
  end  
  
end