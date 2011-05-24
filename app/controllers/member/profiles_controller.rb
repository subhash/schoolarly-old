class Member::ProfilesController < Member::BaseController
  
  def show
    @profile = Profile.find(params[:id])
    retrieve_smerf_form(@profile.form_code, @profile.user)
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
  
  def edit
    @profile = current_user.profile
    puts '@profile - '+@profile.inspect
    retrieve_smerf_form(@profile.form_code, @profile.user)
  end
  
  def update
    @profile = current_user.profile
    @profile.update_attributes(params[:profile])
    if @profile.save and handle_dynamic_responses(params)
      flash[:ok] = I18n.t("tog_social.profiles.member.updated")
      redirect_to member_profile_path(@profile)
    else
      render 'edit'
    end
  end
  
  private
  
  def retrieve_smerf_form(code, user)
    return unless (File.file?(SmerfFile.smerf_file_name(code)))
    # Retrieve the smerf form record if it exists
    @smerfform = SmerfForm.find_by_code(code)
    # Check if smerf form is active
    if (!@smerfform.code.blank?() and !@smerfform.active?())
      raise(RuntimeError, "#{@smerfform.name} is not active.")
    end   
    # Check if we need to rebuild the form, the form is built
    # the first time and then whenever the form definition file
    # is changed
    if (@smerfform.code.blank?() or 
      SmerfFile.modified?(code, @smerfform.cache_date))        
      @smerfform.rebuild_cache(code)
    end
    # Find the smerf form record for the current user
    @smerf_forms_user = SmerfFormsUser.find_user_smerf_form(user.id, @smerfform.id)
    @responses = @smerf_forms_user.responses if @smerf_forms_user
  end
  
  def handle_dynamic_responses(params)
    return unless (params.has_key?("responses"))
    @responses = params['responses'] 
    # Retrieve the smerf form record, rails will raise error if not found
    @smerfform = SmerfForm.find(params[:smerf_form_id])
    # Validate user responses
    @errors = Hash.new()    
    @smerfform.validate_responses(@responses, @errors)
    # Save if no errors
    if (@errors.empty?()) 
      if(SmerfFormsUser.find_user_smerf_form(current_user.id, @smerfform.id))
        SmerfFormsUser.update_records(@smerfform.id, current_user.id, @responses)        
      else
        SmerfFormsUser.create_records(@smerfform.id, current_user.id, @responses)
      end
      return true
    else
      return false
    end
    
  end
  
end