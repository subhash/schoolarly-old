class Admin::GroupsController < Admin::BaseController
  
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
  
end