class Member::ProfilesController < Member::BaseController
  
  before_filter :find_profile, :only => [:show, :new_parent, :create_parent]
  before_filter :check_profile, :only => [:edit, :update]
  
  def show    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile }
    end
  end  
  
  def search
    #    @matches = Tog::Search.search(params[:q], {:only => ["Profile"]}, {:page => '1'})
    #    @matches = User.find(:all, :include => :profile, :conditions => ["users.id in (?) and profiles.first_name like ? or profiles.last_name like ? or users.login like ?", current_user.messageable_user_ids, q, q, q]).flatten.paginate({:page => '1'})
    if current_user.admin?
      @matches = Tog::Search.search(params[:q], {:only => ["User"]}, {:page => '1'}) 
    else
      @matches = Tog::Search.search(params[:q], {:only => ["User"], :user => current_user}, {:page => '1'}) 
    end
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @matches }
      format.js {
        profiles = @matches.collect { |m| {:id => m.id, :name => m.profile.full_name}}
        render :text => profiles.to_json
      }
    end
  end
  
  #  def index    
  #    @order_by = params[:order_by] || "profiles.first_name, profiles.last_name"
  #    @page = params[:page] || '1'
  #    @no_of_entries = params[:no_of_entries] || '15'
  #    @sort_order = params[:sort_order] || 'ASC'  
  #    order = @order_by.split(',').collect{|o|o.to_s+" "+@sort_order.to_s}.join(',')
  #    if params[:group]
  #      condition = ""
  #      conditions_values = Hash.new  
  #      @group = Group.find(params[:group])
  #      @column_groups = params[:subtree] ? @group.subtree : @group.active_children  
  #      conditions_values[:group_id] = @group.id
  #      conditions_values[:person_type] = params[:type]
  #      condition += "(memberships.group_id = :group_id and users.person_type = :person_type)"
  #      if params[:search_term]
  #        condition+= " and "
  #        conditions_values[:search_term] = "%#{params[:search_term]}%"
  #        condition = "(profiles.first_name like :search_term or profiles.last_name like :search_term or users.email like :search_term)"
  #      end     
  #      @profiles = Profile.for_group(condition, conditions_values).paginate :per_page => @no_of_entries,
  #                                 :page => @page,
  #                                 :order => "#{order}" 
  #      @type = @profiles.first.user.type
  #      
  #    else
  #      @profiles = Profile.active.paginate :per_page => @no_of_entries,
  #                                 :page => @page,
  #                                 :order => "#{order}"     
  #    end 
  #    respond_to do |format|
  #      format.html # index.html.erb
  #      format.xml  { render :xml => @profiles }
  #    end
  #  end
  
  def index    
    if params[:group]
      @group = Group.find(params[:group])
      @viewable = current_user.can_view_email?(@group, params[:type])
      if params[:type] == 'Parent'
        @column_groups = []
        @users = @group.parent_users
      else
        @column_groups = @group.active_children  
        @users = @group.users.of_type(params[:type])       
        #      group valid memberships by user id
        @memberships = Membership.find_all_by_user_id_and_group_id(@users.map(&:id), @column_groups.map(&:id)).group_by(&:user_id)
        #      convert the hash to hold only group ids instead of memberships
        @memberships.each{|key, value| @memberships[key] = value.map(&:group_id)}
      end    
      @type = @users.first.type
    else
      @users = User.all
      @column_groups = []
    end 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end
  
  def edit
  end
  
  def update
    @profile.update_attributes(params[:profile])
    if @profile.save
      flash[:ok] = I18n.t("tog_social.profiles.member.updated")
      redirect_to member_profile_path(@profile)
    else
      render 'edit'
    end
  end
  
  def create_parent
    @user = User.new(params[:user])
  end
  
  private
  
  def find_profile
    @profile = Profile.find(params[:id]) if params[:id]
  end
  
  def check_profile
    @profile = Profile.find(params[:id]) if params[:id]
    raise UnauthorizedException.new unless (current_user.profile == @profile or current_user.school_moderator_for?(@profile.user))
  end
  
end
