class Member::GroupsController
  
  def new
    @parent = Group.find(params[:id]) if params[:id]
    @group = Group.new(:parent => @parent)
  end
  
  def invite
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    users = users_to_invite(@group)
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
            invite_user(group,user)
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
  def users_to_invite(group)
    group.parent ? (group.parent.members - group.members) : (User.active - group.members)
  end
  
  def invite_user(group,user)
    group.invite(user)
  end
end