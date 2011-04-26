class GroupsController < ApplicationController
  
  before_filter :login_required, :only => [:join, :leave]
  before_filter :load_group, :only => [:show, :join, :leave, :members, :accept_invitation, :reject_invitation, :share, :sharings]
  
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
    @page = params[:page] || '1'
    @filter = params[:filter] || 'All'
    if @filter == 'All'
      @shares = @group.sharings.paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"
    else
      @shares = @group.sharings.of_type(@filter).paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"  
    end
    respond_to do |wants|
      wants.html
      wants.js do
        render :update do |page|
          page.replace_html 'sharings', :partial => 'member/sharings/sharings'
        end
      end
    end
  end
  
end