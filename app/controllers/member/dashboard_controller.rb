class Member::DashboardController < Member::BaseController
  
  def index
    @profile = current_user.profile 
    @order = params[:order] || 'updated_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @filter = params[:filter] || 'All'
    if @filter == 'All'
      @shares = Share.shared_to_groups(current_user.group_ids).paginate  :per_page => 1,
                                                  :page => @page,
                                                  :order => "#{@order} #{@asc}"
    else
      @shares = Share.shared_to_groups_of_type(@profile.user.group_ids, @filter).paginate :per_page => 1,
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