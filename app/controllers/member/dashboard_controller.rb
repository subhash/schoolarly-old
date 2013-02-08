class Member::DashboardController < Member::BaseController
  
  helper "picto/base"
  
#  def index
#    store_location
#    @profile = current_user.profile 
#    @order = params[:order] || 'updated_at'
#    @page = params[:page] || '1'
#    @asc = params[:asc] || 'desc'
#    @filter = params[:filter] || 'All'
#    group_ids = current_user.group_ids
#    user_ids = [current_user.id]
#    if current_user.parent?
#      group_ids += current_user.friend_users.inject([]) {|c, u| c += u.group_ids}
#      user_ids += current_user.friend_users.map(&:id)
#    end
#    if current_user.admin?
#      group_ids = Group.all.collect(&:id)
#    elsif current_user.school_admin?
#      group_ids += current_user.school.group.descendants.collect(&:id)
#    else
#      group_ids += current_user.moderated_groups.block.collect{|b|b.descendants.collect(&:id)}.flatten
#    end     
#    if @filter == 'All'
#      @shares = Share.to_groups_and_users(group_ids, user_ids).paginate  :per_page => 20,
#                                                  :page => @page,
#                                                  :order => "#{@order} #{@asc}"
#    else
#      @shares = Share.to_groups_and_users_of_type(group_ids, user_ids, @filter).paginate :per_page => 20,
#                                           :page => @page, 
#                                           :order => "#{@order} #{@asc}" 
#    end
#    respond_to do |wants|
#      wants.html
#      wants.js do
#        render :update do |page|
#          page.replace_html 'sharings', :partial => 'member/sharings/sharings'
#          page.call "applyPrettyPhoto"
#        end
#      end
#    end
#  end

  def index
    store_location
    @profile = current_user.profile 
    group_ids = current_user.group_ids
    user_ids = [current_user.id]
    if current_user.parent?
      group_ids += current_user.friend_users.inject([]) {|c, u| c += u.group_ids}
      user_ids += current_user.friend_users.map(&:id)
    end
    if current_user.admin?
      group_ids = Group.all.active.collect(&:id)
    elsif current_user.school_admin?
      group_ids += current_user.school.group.descendants.select(&:active?).collect(&:id)
    else
      group_ids += current_user.moderated_groups.block.collect{|b|b.descendants.collect(&:id)}.flatten
    end     
    
    @shares = Share.to_groups_and_users(group_ids, user_ids)
                                                 
    respond_to do |wants|
      wants.html
      wants.js do
        render :update do |page|
          page.replace_html 'sharings', :partial => 'member/sharings/sharings'
          page.call "applyPrettyPhoto"
        end
      end
    end
  end
  
  
  def set_javascripts_and_stylesheets
    @javascripts = %w(application)
    @stylesheets = %w()
    @feeds = %w()
  end 
  
end
