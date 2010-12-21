class Member::GroupsController < Member::BaseController
  def new
    @parent = Group.find(params[:id]) if params[:id]
    @group = Group.new(:parent => @parent)
  end
  
  def invite
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
  
end