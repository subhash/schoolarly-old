class Admin::GroupsController < Admin::BaseController
  
  def index
    @type = params[:type] || 'groups'
    @order = params[:order] || 'name'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    groups = (@type == 'schools') ? Group.school : Group.all
    @groups = groups.paginate  :per_page => 50,
                                            :page => @page,
                                            :order => @order + " " + @asc
    respond_to do |format|
      format.html
      format.rss { render(:layout => false) }
    end
  end
  
  def activate
    @group = Group.find(params[:id])
    @group.activate!
    respond_to do |wants|
      if @group.activate!
        wants.html do
          render :text => "<span>#{I18n.t("tog_social.groups.admin.activated")}</span>"
        end
      end
    end
  end
  
  def reinvite_parents
    @group = Group.find(params[:id])
    @users = []
    @group.parent_users.each do |user|
      unless user.password_reset_code.blank?
        UserMailer.deliver_signup_invitation_notification(user, current_user)
        @users << user
      end 
    end
    respond_to do |wants|
      wants.html do
        str = "New parents reinvited #{@users.size} :"
        @users.each {|u| str += "<li>#{u.email}</li>"}
        render :text => "<ul>#{str}</ul>"
      end
    end
  end  
  
end