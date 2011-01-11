class Member::SubjectsController < Member::GroupsController
  
  before_filter :find_klass, :only => [:index, :new, :create]
  
  def create
    @group = Group.new(params[:group])
    @group.parent = @klass.group
    @group.author = current_user
    @group.moderated = true
    @group.private = false
    @group.network = Subject.new
    @group.save  
    if @group.errors.empty?     
      @group.join(current_user, true)
      @group.activate!
      flash[:ok] = I18n.t("subjects.member.created", :subject_name => @group.name, :klass_name => @group.parent.name)
      redirect_back_or_default member_subject_path(@group.network)
    else
      render :action => 'new'
    end    
  end
  
  def invite
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    users = @group.parent.student_users - (@group.parent.children.klass.collect(&:student_users)).flatten
    @profiles = users.collect(&:profile).paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
    :page => @page,
    :order => "profiles.#{@order} #{@asc}"
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @profiles }
    end
  end
  
  def add
    if @group.can_invite?(current_user)
      params[:members].each do |profile_id|
        user = Profile.find(profile_id).user
        if @group.members.include? user
          flash[:notice] = I18n.t("groups.site.already_member", :user_name => user.profile.full_name)
          redirect_to invite_member_subject_path(@group) and return
        else
          if @group.invited_members.include? user
            flash[:error] = I18n.t("groups.site.invite.already_invited", :user_name => user.profile.full_name)
            redirect_to invite_member_subject_path(@group) and return
          else
            @group.invite_and_accept(user)
            KlassMailer.deliver_welcome(@group, current_user, user)            
          end
        end        
      end
      flash[:ok] = I18n.t("groups.site.invite.invited", :user_count => params[:members].count)      
    else
      flash[:error] = I18n.t("tog_social.groups.site.invite.you_could_not_invite")    
    end
    redirect_to path_for_group(@group)
  end
  
  protected
  
  def find_group
    @group = Subject.find(params[:id]).group if params[:id]
  end
  
  def find_klass
    @klass = Klass.find(params[:klass_id])
  end
  
  
end