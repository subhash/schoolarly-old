class Member::DashboardController < Member::BaseController
  
  def index
    @profile = current_user.profile 
    @order = params[:order] || 'updated_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @shares = Share.shared_to_groups(current_user.group_ids).sort_by{|share|share.shareable.updated_at}.reverse.paginate  :per_page => 10,
                                                :page => @page,
                                                :order => "#{@order} #{@asc}"  
  end
  
end