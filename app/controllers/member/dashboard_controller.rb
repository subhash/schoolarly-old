class Member::DashboardController < Member::BaseController
  
  def index
    @profile = current_user.profile 
    @order = params[:order] || 'updated_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @filter = params[:filter] || 'All'
    group_ids = current_user.group_ids
    if current_user.parent?
      group_ids += current_user.profile.friends.inject([]) {|c, p| c += p.user.group_ids}
    end
    if @filter == 'All'
      @shares = Share.shared_to_groups(group_ids).paginate  :per_page => 10,
                                                  :page => @page,
                                                  :order => "#{@order} #{@asc}"
    else
      @shares = Share.shared_to_groups_of_type(group_ids, @filter).paginate :per_page => 10,
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