class Member::GroupsController
  
  helper_method :path_for_group
  
  def path_for_group(group)
    case group.network_type
      when 'School'
      school_path(group.network)
      when  'Klass'
      member_klass_path(group.network)
    else
      group_path(group) 
    end    
  end
  
  def new
    @parent = Group.find(params[:id]) if params[:id]
    @group = Group.new(:parent => @parent)
  end
  
  def invite2
    user = User.find(params[:user_id])
    if @group.can_invite?(current_user)
      if @group.members.include? user
        flash[:notice] = I18n.t("tog_social.groups.site.already_member")
      else
        if @group.invited_members.include? user
          flash[:error] = I18n.t("tog_social.groups.site.invite.already_invited")
        else
          @group.invite(user)
          GroupMailer.deliver_invitation(@group, current_user, user)
          flash[:ok] = I18n.t("tog_social.groups.site.invite.invited")
        end
      end
    else
      flash[:error] = flash[:error] = I18n.t("tog_social.groups.site.invite.you_could_not_invite")
    end
    redirect_to invite_to_group_path(@group)
  end
  
  def invite
    if @group.can_invite?(current_user)
      params[:members].each do |profile_id|
        user = Profile.find(profile_id).user
        if @group.members.include? user
          flash[:notice] = I18n.t("groups.site.already_member", :user_name => user.profile.full_name)
          redirect_to invite_to_group_path(@group)
        else
          if @group.invited_members.include? user
            flash[:error] = I18n.t("groups.site.invite.already_invited", :user_name => user.profile.full_name)
            redirect_to invite_to_group_path(@group)
          else
            @group.invite(user)
            GroupMailer.deliver_invitation(@group, current_user, user)            
          end
        end        
      end
      flash[:ok] = I18n.t("groups.site.invite.invited", params[:members].count)      
    else
      flash[:error] = I18n.t("tog_social.groups.site.invite.you_could_not_invite")    
    end
    redirect_to path_for_group(@group)
  end
  
end