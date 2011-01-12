class Member::GroupsController
  
  before_filter :find_type, :only => [:new,:create]
  
  def new
    @parent = Group.find(params[:id]) if params[:id]
    @group = Group.new(:parent => @parent)
  end
  
  def create
    @group = Group.new(params[:group])
    @group.author = current_user
    case @type
      when 'schools':
      @group.network = School.new
    end
    @group.network.initialize_group if @group.network
    @group.save   
    
    if @group.errors.empty?
      
      @group.join(current_user, true)
      #    @group.activate_membership(current_user)
      
      if current_user.admin == true || Tog::Config['plugins.tog_social.group.moderation.creation'] != true
        @group.activate!
        flash[:ok] = I18n.t("tog_social.groups.member.created")
        redirect_to group_path(@group)
      else
        
        admins = User.find_all_by_admin(true)        
        admins.each do |admin|
          Message.new(
            :from => current_user,
            :to   => admin,
            :subject => I18n.t("#{@type}.member.mail.activation_request.subject", :group_name => @group.name),
            :content => I18n.t("#{@type}.member.mail.activation_request.content", 
                               :user_name   => current_user.profile.full_name, 
                               :group_name => @group.name, 
                               :activation_url => edit_admin_group_url(@group)) 
          ).dispatch!     
        end
        
        flash[:warning] = I18n.t("#{@type}.member.pending")
        redirect_to groups_path
      end
    else
      render :action => 'new'
    end
    
  end
  
  
  def invite
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    users = @group.parent ? (@group.parent.members - @group.members) : (User.active - @group.members)
    @profiles = users.collect(&:profile).paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                 :page => @page,
                                 :order => "profiles.#{@order} #{@asc}"
    respond_to do |format|
      format.html { render :template => 'member/groups/invite'}
      format.xml  { render :xml => @profiles }
    end
  end
  
  def add
    if @group.can_invite?(current_user)
      params[:members].each do |profile_id|
        user = Profile.find(profile_id).user
        if @group.members.include? user
          flash[:notice] = I18n.t("groups.site.already_member", :user_name => user.profile.full_name)
          redirect_to invite_member_group_path(@group) and return
        else
          if @group.invited_members.include? user
            flash[:error] = I18n.t("groups.site.invite.already_invited", :user_name => user.profile.full_name)
            redirect_to invite_member_group_path(@group) and return
          else
            @group.invite(user)
            GroupMailer.deliver_invitation(@group, current_user, user)            
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
  def find_type
    @type = params[:type] || 'groups'
  end
  
end