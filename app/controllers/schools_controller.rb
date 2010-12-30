class SchoolsController < GroupsController
  
  def index
    @order = params[:order] || 'schools.created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @schools = School.active.paginate  :per_page => 10,
                                            :page => @page,
                                            :order => @order + " " + @asc
    respond_to do |format|
      format.html
      format.rss { render(:layout => false) }
    end
  end
  
end