require "csv"

class Member::GroupsController < Member::BaseController 
  before_filter :find_parent, :only => [:new, :new_multiple, :create_multiple]
  before_filter :find_type, :only => [:new,:create, :new_multiple, :create_multiple]
  before_filter :find_group, :except => [:index, :new, :create, :new_multiple, :create_multiple]
  before_filter :check_moderator, :except => [:index, :new, :create, :new_multiple, :create_multiple, :invite, :accept_invitation, :reject_invitation, :show]
  
  
  
  def create_multiple
    @groups = []
    @failed_groups = []
    CSV.parse(params[:groups]) do |row|
      group = Group.new(:name => row[0].strip, :parent => @parent)
      group.description = row[1].strip if row[1]
      group.author = current_user
      case @type
        when 'schools':
        group.network = School.new    
        group.moderated = true
        group.private = false
        when 'klasses':
        group.network = Klass.new    
        group.moderated = true
        group.private = false
        when 'subjects':
        group.network = Subject.new    
        group.moderated = true
        group.private = false
      end
      group.save   
      if group.errors.empty?    
        group.join(current_user, true)
        #    group.activate_membership(current_user)
        #      activate child groups directly
        if (group.parent and group.parent.active?) 
          group.activate!
        else        
          admins = User.find_all_by_admin(true)        
          admins.each do |admin|
            Message.new(
            :from => current_user,
            :to   => admin,
            :subject => I18n.t("#{@type}.member.mail.activation_request.subject", :group_name => group.name),
            :content => I18n.t("#{@type}.member.mail.activation_request.content", 
                               :user_name   => current_user.profile.full_name, 
                               :group_name => group.name, 
                               :activation_url => edit_admin_group_url(group)) 
            ).dispatch!     
          end
        end
      else
        @failed_groups << row.join(",")
      end  
      @groups << group
    end
    if @failed_groups.blank?
      flash[:ok] = I18n.t("#{@type}.site.add_multiple.added", :count => @groups.count)      
      redirect_to member_group_path(@parent)
    else    
      @failed_groups = @failed_groups.join("\n")
      render :action => 'new_multiple'
    end
  end
  
  
  def new
    @group = Group.new(:parent => @parent)
  end
  
  def create
    @group = Group.new(params[:group])
    @group.author = current_user
    case @type
      when 'schools':
      @group.network = School.new    
      @group.moderated = true
      @group.private = false
      when 'klasses':
      @group.network = Klass.new    
      @group.moderated = true
      @group.private = false
      when 'subjects':
      @group.network = Subject.new    
      @group.moderated = true
      @group.private = false
    end
    @group.save   
    
    if @group.errors.empty?
      
      @group.join(current_user, true)
      #    @group.activate_membership(current_user)
      #      activate child groups directly
      if (@group.parent and @group.parent.active?) || current_user.admin == true || Tog::Config['plugins.tog_social.group.moderation.creation'] != true
        @group.activate!
        flash[:ok] = I18n.t("tog_social.groups.member.created")
        redirect_to member_group_path(@group)
      else        
        admins = User.find_all_by_admin(true)        
        admins.each do |admin|
          Message.new(
            :from => current_user,
            :to   => admin,
            :subject => I18n.t("#{@type}.member.mail.activation_request.subject", :group_name => @group.name),
            :content => I18n.t("#{@type}.member.mail.activation_request.content", 
                               :user_name   => current_user.profile.full_name, 
                               :group_name => @group.name, 
                               :activation_url => edit_admin_group_url(@group)) 
          ).dispatch!     
        end
        
        flash[:warning] = I18n.t("#{@type}.member.pending")
        redirect_back_or_default member_groups_path
      end
    else
      render :action => 'new'
    end
    
  end
  
  def add_select
    @type = params[:type]
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    @profiles = @group.applicable_members(@type).collect(&:profile).paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                 :page => @page,
                                 :order => "profiles.#{@order} #{@asc}"
    respond_to do |format|
      format.html { render :template => 'member/groups/add_select'}
      format.xml  { render :xml => @profiles }
    end    
  end
  
  def add
    unless params[:members]
      flash[:error] = I18n.t("groups.site.select.none_selected", :types => params[:type].downcase.pluralize)    
      redirect_to add_select_member_group_path(@group, :type => params[:type]) and return
    end
    if @group.can_invite?(current_user)
      params[:members].each do |profile_id|
        user = Profile.find(profile_id).user
        if @group.members.include? user
          flash[:notice] = I18n.t("groups.site.already_member", :user_name => user.profile.full_name)
          redirect_to add_select_member_group_path(@group, :type => params[:type]) and return
        else
          if @group.invited_members.include? user
            flash[:error] = I18n.t("groups.site.select.already_invited", :user_name => user.profile.full_name)
            redirect_to add_select_member_group_path(@group, :type => params[:type]) and return
          else
            @group.invite_and_accept(user)
            @group.grant_moderator(user) unless params[:moderator].blank?
            GroupMailer.deliver_entry_notification(@group, current_user, user)  
            #           TODO Send notification to other moderators
          end
        end        
      end
      flash[:ok] = I18n.t("groups.site.select.invited", :user_count => params[:members].count)      
    else
      flash[:error] = I18n.t("tog_social.groups.site.invite.you_could_not_invite")    
    end
    redirect_to member_group_path(@group)
  end
  
  def remove_select
    @type = params[:type]
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @removable_members = @group.removable_members(@type) - [current_user]
    @profiles = @removable_members.collect(&:profile).paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                 :page => @page,
                                 :order => "profiles.#{@order} #{@asc}"
    respond_to do |format|
      format.html { render :template => 'member/groups/remove_select'}
      format.xml  { render :xml => @profiles }
    end    
  end
  
  def remove
    params[:members].each do |profile_id|
      user = Profile.find(profile_id).user
      if @group.moderators.include?(current_user)    
        if !@group.members.include?(user) && !@group.pending_members.include?(user)
          flash[:error] = I18n.t("tog_social.groups.site.not_member")
        else
          if @group.moderators.include?(user) && @group.moderators.size == 1
            flash[:error] = I18n.t("tog_social.groups.site.last_moderator")
          else
            @group.leave(user)
            GroupMailer.deliver_exit_notification(@group, current_user, user)
            #          TODO send mail to other moderators
            #todo: eliminar cuando este claro que sucede si un usuario ya es miembro
          end
        end
      else
        flash[:error] = I18n.t("groups.site.not_moderator")
      end
    end
    flash[:ok] = I18n.t("groups.site.remove.removed", :user_count => params[:members].count)      
    redirect_to edit_member_group_path(@group)    
  end
  
  def show
    store_location
    @page = params[:page] || '1'
    @filter = params[:filter] || 'All'
    if @filter == 'All'
      @shares = @group.sharings.paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "updated_at desc"
    else
      @shares = @group.sharings.of_type(@filter).paginate :per_page => 10,
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
  
  def apply
    user = User.find(params[:user_id])
    @smerfform = SmerfForm.find_by_code(@group.network.form_code)
    puts "finding form - #{user.id} - #{@smerfform.id}"
    @smerf_forms_user = SmerfFormsUser.find_user_smerf_form(user.id, @smerfform.id)
    @responses = @smerf_forms_user.responses
  end
  
  protected
  def find_type
    @type = params[:type] || 'groups'
  end
  
  def find_parent
    @parent = Group.find(params[:id]) if params[:id]
  end
  
end