class Member::DashboardController < Member::BaseController
  
  def index
    @profile = current_user.profile 
    @order = params[:order] || 'updated_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @filter = params[:filter] || 'All'
    group_ids = current_user.group_ids
    user_ids = [current_user.id]
    if current_user.parent?
      group_ids += current_user.friend_users.inject([]) {|c, u| c += u.group_ids}
      user_ids += current_user.friend_users.map(&:id)
    end     
    if @filter == 'All'
      @shares = Share.to_groups_and_users(group_ids, user_ids).paginate  :per_page => 10,
                                                  :page => @page,
                                                  :order => "#{@order} #{@asc}"
    else
      @shares = Share.to_groups_and_users_of_type(group_ids, user_ids, @filter).paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "#{@order} #{@asc}" 
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
