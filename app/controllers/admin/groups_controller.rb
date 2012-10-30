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
  
  
end