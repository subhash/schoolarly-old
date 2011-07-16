class Member::StudentsController < Member::BaseController
  
  before_filter :find_group, :except => [:new_parent, :create_parent, :select_parent, :add_parent, :remove_parent]
  
  before_filter :find_student, :only => [:new_parent, :create_parent, :select_parent, :add_parent, :remove_parent]
  
  require "csv"
  
  def create
    @users = []
    @failed_students = []
    @failed_parents = {}
    CSV.parse(params[:students]) do |row|
      name = email = fname = femail = mname = memail = nil
      name, email, fname, femail, mname, memail = row
      user = create_user(email, name, Student.new)      
      if user.invite_over_email(current_user)
        # TODO check if you are allowed to invite
        @group.invite_and_accept(user)
        GroupMailer.deliver_entry_notification(@group, current_user, user)  
        if(femail)
          father = create_user(femail, fname, Parent.new)        
          if father.invite_over_email(current_user)
            user.profile.add_friend(father.profile)
          else
            @failed_parents[user] = father
          end
        end
        if(memail)
          mother = create_user(memail, mname, Parent.new)
          if mother.invite_over_email(current_user)
            user.profile.add_friend(mother.profile)
          else
            @failed_parents[user] = mother
          end
        end
      else
        @failed_students << row.join(",")
      end
      @users << user
    end
    if @failed_students.blank? and @failed_parents.blank?
      flash[:ok] = I18n.t("groups.site.Student.invited", :count => @users.count)      
      redirect_back_or_default(member_group_path(@group))
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
    if @user.invite_over_email(current_user)
      @student.user.profile.add_friend(@user.profile)
      redirect_to member_profile_path(@student.user.profile)
    else
      render :action => 'new_parent'
    end
  end
  
  def add_parent
    unless params[:members]
      flash[:error] = I18n.t("students.site.parent.select.none_selected")    
      redirect_to select_parent_member_student_path(@student) and return
    end
    params[:members].each do |profile_id|
      user = Profile.find(profile_id).user
      unless @student.user.profile.add_friend(user.profile)
        flash[:error] = I18n.t("students.site.parent.select.failure")    
        redirect_to select_parent_member_student_path(@student) and return        
      end
    end
    flash[:ok] = I18n.t("students.site.parent.select.success")    
    redirect_to member_profile_path(@student.user.profile)
  end
  
  def select_parent
    @profiles = []
    @profiles += @student.user.school.group.applicable_members('Parent').map(&:profile) if @student.user.school
    @profiles -= @student.user.profile.parents
  end
  
  def remove_parent
    @parent = Parent.find(params[:parent])
    @student.user.profile.remove_friend(@parent.user.profile)
    redirect_to member_profile_path(@student.user.profile)
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
    email = email.strip if email
    user = User.new(:email => email)
    user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
    user.profile = Profile.new(:first_name => first,:last_name => last)
    user.person = person
    return user
  end
end