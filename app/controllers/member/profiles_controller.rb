class Member::ProfilesController < Member::BaseController
  
  before_filter :find_profile, :only => [:show, :new_parent, :create_parent]
  before_filter :check_profile, :only => [:edit, :update]
  
  helper_method :i_am_school_moderator_for
  
  def show    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile }
    end
  end  
  
  def search
    @matches = Tog::Search.search(params[:q], {:only => ["Profile"]}, {:page => '1'})
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @matches }
      format.js {
        profiles = @matches.collect { |m| {:id => m.user.id, :name => m.full_name}}
        render :text => profiles.to_json
      }
    end
  end
  
  def index    
    @order_by = params[:order_by] || 'profiles.first_name, profiles.last_name'
    @page = params[:page] || '1'
    @sort_order = params[:sort_order] || 'asc'    
    if params[:group]
      condition = ""
      conditions_values = Hash.new  
      @group = Group.find(params[:group])  
      conditions_values[:group_id] = @group.id
      conditions_values[:person_type] = params[:type]
      condition += "(memberships.group_id = :group_id and users.person_type = :person_type)"
      if params[:search_term]
        condition+= " and "
        conditions_values[:search_term] = "%#{params[:search_term]}%"
        condition = "(profiles.first_name like :search_term or profiles.last_name like :search_term or users.email like :search_term)"
      end
      puts "order = "+@order_by.inspect
      @profiles = Profile.for_group(condition, conditions_values, @order_by, @sort_order).paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'],
                                 :page => @page,
                                 :order => "#{@order_by} #{@sort_order}" 
      @type = @profiles.first.user.type
      
    else
      @profiles = Profile.active.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'],
                                 :page => @page,
                                 :order => "#{@order_by} #{@sort_order}"     
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
    raise UnauthorizedException.new unless current_user.profile == @profile or i_am_school_moderator_for(@profile)
  end
  
  def i_am_school_moderator_for(profile)
    schools = profile.user.parent? ? profile.friends.collect{|f| f.user.groups.school}.flatten : profile.user.groups.school
    schools.collect(&:moderators).flatten.include?(current_user)
  end
  
end