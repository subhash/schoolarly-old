class Member::UsersController < Member::BaseController        

  def shares
    filter = params[:filter]
    if filter == 'All'
      @shares = Share.shared_to_groups(@user.group_ids).paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"
    else
      @shares = Share.shared_to_groups_of_type(@user.group_ids,filter).paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"  
    end
    render :update do |page|
      page.replace_html 'sharings', :partial => 'member/users/sharings'
    end
    
  end
end
