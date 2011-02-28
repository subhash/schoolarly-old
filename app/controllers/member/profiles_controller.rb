class Member::ProfilesController < Member::BaseController
  
  def show
    @profile = Profile.find(params[:id])
    store_location
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
        profiles = @matches.collect { |m| {:id => m.id, :name => m.full_name}}
        render :text => profiles.to_json
      }
    end
  end
  
  def index
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    if params[:group]
      @group = Group.find(params[:group])
      @profiles = Profile.for_group_for_type(@group,params[:type]).paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                 :page => @page,
                                 :order => "profiles.#{@order} #{@asc}"  
      @type = @profiles.first.user.type
    else
      @profiles = Profile.active.paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                 :page => @page,
                                 :order => "profiles.#{@order} #{@asc}"     
    end 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end
  
  def shares
    @profile = Profile.find(params[:id])
    filter = params[:filter]
    if filter == 'All'
      @shares = Share.shared_to_groups(@profile.user.group_ids).paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"
    else
      @shares = Share.shared_to_groups_of_type(@profile.user.group_ids,filter).paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"  
    end
    render :update do |page|
      page.replace_html 'sharings', :partial => 'member/profiles/sharings'
    end
    
  end
  
end