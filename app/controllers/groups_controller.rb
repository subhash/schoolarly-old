class GroupsController < ApplicationController
  
  before_filter :login_required, :only => [:join, :leave, :exit_member]
  before_filter :load_group, :only => [:show, :join, :leave, :members, :accept_invitation, :reject_invitation, :share, :exit_member]
  
  def index
    @type = params[:type] || 'groups'
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    groups = (params[:type] == 'schools') ? Group.school.base.active.public : Group.default.base.active.public
    @groups = groups.paginate  :per_page => 10,
                                            :page => @page,
                                            :order => @order + " " + @asc
    respond_to do |format|
      format.html
      format.rss { render(:layout => false) }
    end
  end
  
  def show
    store_location
  end
  
  
  def exit_member
    user = User.find(params[:user_id])
    if @group.moderators.include?(current_user)    
      if !@group.members.include?(user) && !@group.pending_members.include?(user)
        flash[:error] = I18n.t("tog_social.groups.site.not_member")
      else
        if @group.moderators.include?(user) && @group.moderators.size == 1
          flash[:error] = I18n.t("tog_social.groups.site.last_moderator")
        else
          @group.leave(user)
          GroupMailer.deliver_exit_notification(@group, current_user, user)
#          TODO send mail to other moderators
          #todo: eliminar cuando este claro que sucede si un usuario ya es miembro
          flash[:ok] = I18n.t("groups.site.exited", :user_name => user.profile.full_name, :group_name => @group.name)
        end
      end
    else
      flash[:error] = I18n.t("groups.site.not_moderator")
    end
    redirect_back_or_default profiles_path(user)
  end
  
  
end