class Member::StudentsController < Member::BaseController
  
  before_filter :find_group, :except => [:new_parent, :create_parent, :select_parent, :add_parent, :remove_parent]
  
  before_filter :find_student, :only => [:new_parent, :create_parent, :select_parent, :add_parent, :remove_parent]
  
  require "csv"
  
  def create
    @users = []
    @failed_students = []
    @failed_parents = {}

    CSV.parse(params[:students]) do |row|
      user, father, mother = User.from_csv(row)
      if user.new_record? and !user.invite_over_email(current_user)
        @failed_students << row.join(",")
      elsif !user.save
        @failed_students << row.join(",")
      else
        if father.new_record? and !father.invite_over_email(current_user)
          @failed_parents[user] = father
        elsif !father.save
          @failed_parents[user] = father
        else
          user.profile.add_friend(father.profile)
        end if father
        if mother and mother.new_record? and !mother.invite_over_email(current_user)
          @failed_parents[user] = mother
        elsif !mother.save
          @failed_parents[user] = mother
        else
          user.profile.add_friend(mother.profile)
        end if mother
        @group.join(user)
        @users << user
      end if user
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
    @user = User.find_by_email(params[:user][:email])
    unless @user
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
    else
      @student.user.profile.add_friend(@user.profile)
      redirect_to member_profile_path(@student.user.profile)
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

end