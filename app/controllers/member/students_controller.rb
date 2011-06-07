class Member::StudentsController < Member::BaseController
  
  before_filter :find_group, :except => [:new_parent, :create_parent]
  
  before_filter :find_student, :only => [:new_parent, :create_parent]
  
  require "csv"
  
  def create
    @users = []
    @failed_students = []
    CSV.parse(params[:students]) do |row|
      email = name = femail = fname = memail = mname = nil
      email, name, femail, fname, memail, mname = row
      user = create_user(email, name, Student.new)      
      if user.invite_over_email
        # TODO check if you are allowed to invite
        @group.invite_and_accept(user)
        GroupMailer.deliver_entry_notification(@group, current_user, user)  
#           TODO Send notification to other moderators
        father = create_user(femail, fname, Parent.new)
        father.invite_over_email
        mother = create_user(memail, mname, Parent.new)        
        mother.invite_over_email
        user.profile.add_friend(father.profile)
        user.profile.add_friend(mother.profile)
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
  
  def create_parent
    @user = User.new(params[:user])
    # TODO check why nested attributes does not work
    @user.profile = Profile.new(params[:user][:profile])
    @user.login ||= @user.email if Tog::Config["plugins.tog_user.email_as_login"]
    @user.person = Parent.new
    if @user.invite_over_email
      @student.user.profile.add_friend(@user.profile)
      redirect_to member_profile_path(@student.user.profile)
    else
      render :action => 'new_parent'
    end
  end
  
  
  private
  def find_group
    @group = Group.find(params[:group_id])
  end
  
  def find_student
    @student = Student.find(params[:id]) if params[:id]
  end
  
  def create_user(email, name, person)
      first = last = nil
      first, last = name.split(' ',2) if name
      user = User.new(:email => email.strip)
      user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
      user.profile = Profile.new(:first_name => first,:last_name => last)
      user.person = person
      return user
  end
end