class Admin::ProfilesController < Admin::BaseController
  
  helper_method :show_subgroup_memberships?
  
  def index    
    if params[:group]
      @group = Group.find(params[:group])
      @can_view_email = current_user.can_view_email?(@group)
      if params[:type] == 'Parent'
        @users = @group.parent_users
      else 
        @users = @group.users.of_type(params[:type])
      end
      if (!show_subgroup_memberships?(@group,@type) && !(params[:type] == 'Parent'))
        @column_groups = []
        klass_groups = @group.active_children.klass
        @memberships  = Membership.find(:all, :include => :group, :conditions => {:user_id => @users.map(&:id), :group_id => klass_groups.map(&:id)}).group_by(&:user_id)
      else
        if params[:type] == 'Parent'
          @column_groups = []
        else
          @column_groups = @group.active_children  
          @memberships = Membership.find(:all, :conditions => {:user_id => @users.map(&:id), :group_id => @column_groups.map(&:id)}).group_by(&:user_id)
          @memberships.each do |key, value|
            h = {}
            value.each{|m| h[m.group_id] = m}
            @memberships[key] = h
          end
        end 
      end
      @type = @users.empty? ? params[:type].pluralize.parameterize : @users.first.type
    else
      @users = User.all
      @column_groups = []
    end 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end
  
  
  def show_subgroup_memberships? (group, type)   
    !group.school? && (!group.block? || !(type.pluralize.parameterize == 'students'))
  end
  
end