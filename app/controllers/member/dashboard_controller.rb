class Member::DashboardController < Member::BaseController
  
  helper "picto/base"
  
  def index
    store_location
    @profile = current_user.profile 
    @order = params[:order] || 'updated_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @filter = params[:filter] || 'All'
    group_ids = current_user.group_ids
    user_ids = [current_user.id]
    puts "before current_user.parent?"
    if current_user.parent?
      group_ids += current_user.friend_users.inject([]) {|c, u| c += u.group_ids}
      user_ids += current_user.friend_users.map(&:id)
    end
    puts "after current_user.parent?"
    puts "before block"
    if current_user.admin?
      group_ids = Group.all.collect(&:id)
    elsif current_user.school_admin?
      group_ids += current_user.school.group.descendants.collect(&:id)
    else
      puts "inside block - else "
      group_ids += current_user.moderated_groups.block.collect{|b|b.descendants.collect(&:id)}.flatten
    end     
    puts "outside block"
    if @filter == 'All'
      puts 'before shares'
      @shares = Share.to_groups_and_users(group_ids, user_ids).paginate  :per_page => 20,
                                                  :page => @page,
                                                  :order => "#{@order} #{@asc}"
      puts 'after shares'
    else
      @shares = Share.to_groups_and_users_of_type(group_ids, user_ids, @filter).paginate :per_page => 20,
                                           :page => @page, 
                                           :order => "#{@order} #{@asc}" 
    end
    respond_to do |wants|
      puts 'before rendering'
      wants.html
      puts 'after rendering'
      wants.js do
        render :update do |page|
          page.replace_html 'sharings', :partial => 'member/sharings/sharings'
          page.call "applyPrettyPhoto"
        end
      end
    end
  end
  
end
