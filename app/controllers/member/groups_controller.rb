require "csv"

class Member::GroupsController < Member::BaseController
  
  helper "picto/base"
  
  before_filter :find_parent, :only => [:new, :new_multiple, :create_multiple]
  before_filter :find_groups_type, :only => [:new,:create, :new_multiple, :create_multiple]
  before_filter :find_group, :except => [:index, :new, :create, :new_multiple, :create_multiple]
  before_filter :check_moderator, :only => [:edit, :update, :add_select, :remove_select, :add, :remove, :select_moderators, :add_moderators, :remove_moderator, :edit_profiles, :update_profiles]
  before_filter :find_moderator, :only => [:remove_moderator]
  before_filter :find_user_type, :only => [:add_select, :remove_select, :select_moderators]
  
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
    @group.moderated = true
    @group.private = false
    case @type
      when 'schools':
      @group.network = School.new    
      when 'klasses':
      @group.network = Klass.new 
      when 'blocks':
      @group.network = Block.new  
      when 'subjects':
      @group.network = Subject.new
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
    params[:external] ||= false 
    if params[:external]
      @profiles = @group.applicable_members(@type, current_user).collect(&:profile)
    else
      @profiles = @group.applicable_members(@type).collect(&:profile) 
    end   
    respond_to do |format|
      format.html { render :template => 'member/groups/add_select'}
      format.xml  { render :xml => @profiles }
    end   
  end
  
  
  def remove_select
    @removable_members = @group.removable_members(@type) - [current_user]
    @profiles = @removable_members.collect(&:profile)
    respond_to do |format|
      format.html { render :template => 'member/groups/remove_select'}
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
            @group.grant_moderator(user) unless (params[:moderator].blank? || (params[:moderator] == 'false'))
            #        commenting out entry into group email for now
            #            GroupMailer.deliver_entry_notification(@group, current_user, user)  
          end
        end        
      end
      flash[:ok] = I18n.t("groups.site.select.invited", :user_count => params[:members].count)      
    else
      flash[:error] = I18n.t("tog_social.groups.site.invite.you_could_not_invite")    
    end
    respond_to do |wants|
      wants.html{ redirect_to member_group_path(@group)}
      wants.js {
        render :update do |page|
          page.replace_html "user_#{params[:members].first}_group_#{@group.id}", :partial => 'member/groups/add'
        end
      }
    end
  end
  
  def remove
    params[:members].each do |profile_id|
      user = Profile.find(profile_id).user
      if @group.moderators.include?(current_user)    
        if !@group.members.include?(user) && !@group.pending_members.include?(user)
          flash[:error] = I18n.t("tog_social.groups.site.not_member")
        else
          if @group.last_moderator?(user)
            flash[:error] = I18n.t("groups.site.last_moderator")
          else
            if @group.leave(user)
              GroupMailer.deliver_exit_notification(@group, current_user, user)
            else
              flash[:error] = I18n.t("groups.site.edit.moderators.remove.last_moderator_in_child", :user_name => user.name, :group_name => @group.name)
            end
          end
        end
      else
        flash[:error] = I18n.t("groups.site.not_moderator")
      end
    end
    flash[:ok] = I18n.t("groups.site.remove.removed", :user_count => params[:members].count) 
    respond_to do |wants|
      wants.html{ redirect_to edit_member_group_path(@group)}
      wants.js {
        render :update do |page|
          page.replace_html "user_#{params[:members].first}_group_#{@group.id}", :partial => 'member/groups/remove'          
        end
      }
    end
    
  end
  
  def show
    store_location
    @page = params[:page] || '1'
    @filter = params[:filter] || 'All'
    if @filter == 'All'
      @shares = @group.sharings.paginate :per_page => 20,
                                           :page => @page, 
                                           :order => "updated_at desc"
    else
      @shares = @group.sharings.of_type(@filter).paginate :per_page => 20,
                                           :page => @page, 
                                           :order => "updated_at desc"  
    end
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
  
  def apply
    user = User.find(params[:user_id])
    @smerfform = SmerfForm.find_by_code(@group.network.form_code)
    puts "finding form - #{user.id} - #{@smerfform.id}"
    @smerf_forms_user = SmerfFormsUser.find_user_smerf_form(user.id, @smerfform.id)
    @responses = @smerf_forms_user.responses
  end
  
  def select_moderators
    @profiles = @group.moderator_candidates.collect(&:profile)
    @form_url = add_moderators_member_group_path(@group)
    @form_title = I18n.t("groups.site.edit.moderators.select.title")
    @form_submit = I18n.t("groups.site.edit.moderators.select.submit")
    render :template => 'member/groups/remove_select'
  end
  
  def add_moderators
    unless params[:members]
      flash[:error] = I18n.t("groups.site.edit.moderators.select.none")    
      redirect_to select_moderators_member_group_path(@group) and return
    end
    added_users = []
    params[:members].each do |profile_id|
      user = Profile.find(profile_id).user
      unless @group.grant_moderator(user)
        flash[:error] = I18n.t("groups.site.edit.moderators.add.failure", :user_name => user.profile.full_name, :group_name => @group.name)
        render 'edit'
      end
      GroupMailer.deliver_add_moderator_notification(@group, current_user, user)
      added_users << user.profile.full_name
    end
    flash[:ok] = I18n.t("groups.site.edit.moderators.add.success", :user_name => added_users.join(", "), :group_name => @group.name)
    redirect_to edit_member_group_path(@group)
  end
  
  def remove_moderator
    if @group.moderators.size <= 1
      flash[:error] = I18n.t("groups.site.edit.moderators.remove.last_moderator", :user_name => @moderator.profile.full_name, :group_name => @group.name)
      render 'edit'
    elsif @group.revoke_moderator(@moderator)
      flash[:ok] = I18n.t("groups.site.edit.moderators.remove.success", :user_name => @moderator.profile.full_name, :group_name => @group.name)
      GroupMailer.deliver_revoke_moderator_notification(@group, current_user, @moderator)
      redirect_to edit_member_group_path(@group)
    else
      flash[:error] = I18n.t("groups.site.edit.moderators.remove.failure", :user_name => @moderator.profile.full_name, :group_name => @group.name)
      render 'edit'
    end    
  end
  
  def update
    @group.update_attributes!(params[:group])
    @group.tag_list = params[:group][:tag_list]
    @group.save
    flash[:ok] =  I18n.t("tog_social.groups.member.updated", :name => @group.display_name) 
    redirect_to member_group_path(@group)
  end
  
  def archive
    date = Date.today.to_s(:db)
    new_name = @group.name + "[Archived on "+date+"]"
    @group.update_attributes!(:name => new_name)
    @group.archive!
    redirect_to member_group_path(@group)
  end
  
  def reactivate
    new_name = @group.name.split("[Archived on")[0]
    @group.update_attributes!(:name => new_name)
    @group.reactivate!
    redirect_to member_group_path(@group)
  end
  
  
  def update_profiles
    @users = params[:users]
    parsed = parse_csv(@users)
    if parsed.blank?
      flash[:error] = I18n.t('groups.member.edit_profiles.error.mismatch')
      render 'edit_profiles' and return
    end
    unless parsed.first["email"]
      flash[:error] = I18n.t('groups.member.edit_profiles.error.email_missing')
      render 'edit_profiles' and return
    end
    @ok_users = []
    @error_users = []
    @users = []
    @failed_parents = {}
    @ok_parents = {}
    @users << parsed.first.keys.join(",")
    parsed.each do |attr_hash|
      dup_hash = attr_hash.dup
      email = dup_hash.delete("email")
      user = User.find_by_email(email)
      if user
        add_parents(user, dup_hash)
        profile = user.profile
        dup_hash.each do |k, v|
          if profile.attributes.include? k or profile.attributes_list.include? k 
            profile.send(profile.attributes_list.include?(k)?"field_#{k}=":"#{k}=", v)
          else
            user.errors.add k.to_s, "is an invalid attribute"
          end
        end
        if profile.errors.blank? and user.errors.blank? and profile.save
          @ok_users << user
        else
          @error_users << user
          @users << attr_hash.values.join(",")
        end
      else
        user = User.new(:email => email)
        user.errors.add "email", "does not exist"
        @error_users << user
        @users << attr_hash.values.join(",")        
      end
    end
    unless @error_users.blank? and @failed_parents.blank?
      @users = @users.join("\n")
      render 'edit_profiles'      
    else
      flash[:ok] = I18n.t('groups.member.edit_profiles.ok.notice', :user_count => @ok_users.size)
      redirect_to edit_member_group_path(@group)
    end
    
  end
  
  def select_groups
    @groups = current_user.admin? ? Group.all : current_user.groups
  end
  
  def select_subgroups
    @groups = @group.school.group.descendants - @group.self_and_descendants
  end
  
  def add_subgroups
    @memberships = Membership.active.find_all_by_group_id(params[:group_ids])
    @memberships.each do |membership|
      user = membership.user
      group = membership.group
      @group.invite_and_accept(user) unless @group.users.include?(user)
      @group.grant_moderator(user) unless (params[:moderator].blank? || (params[:moderator] == 'false'))
      group.parent = @group
      group.save!
    end
    @group.save!   
    flash[:ok] = "Groups added successfully"
    redirect_to member_group_path(@group)
  end
  
  def add_groups
    source = Group.find(params[:source])
    target = @group
    source.users.each do |user| 
      target.invite_and_accept(user) unless target.users.include?(user)
      target.grant_moderator(user) if source.moderators.include?(user)
    end
    flash[:ok] = "Added from #{source.path} to #{target.path}"
    redirect_to select_groups_member_group_path(@group)
  end
  
  def stats
    @subtree = @group.self_and_descendants
    @shares = Share.shared_to_groups(@subtree).group_by(&:shareable_type)
    @messages = @shares['Notice'] || []
    @notes = @shares['Post'] || []
    @photos = @shares['Picto::Photo'] || []
    @activities = @shares['Assignment'] || []
    @videos = @shares['Video'] || []
  end
  
  protected
  def find_groups_type
    @type = params[:type] || 'groups'
  end
  
  def find_parent
    @parent = Group.find(params[:id]) if params[:id]
  end
  
  def find_moderator
    @moderator = User.find(params[:moderator]) if params[:moderator]
  end
  
  def find_user_type
    @type = params[:type]
  end
  
  def check_moderator
    unless (current_user.admin? || (@group.moderators.include? current_user))
      flash[:error] = I18n.t("tog_social.groups.member.not_moderator") 
      redirect_to member_group_path(@group)
    end
  end
  
  private
  
  def parse_csv(csv)
    results = []
    header = nil
    CSV.parse(csv) do |row|
      unless header
        header = row.map {|c| c.to_s}
      else
        return nil unless row.size == header.size 
        p = ActiveSupport::OrderedHash.new
        row.each_with_index do |val, i|
          p[header[i].strip] = val.to_s.strip
          puts p.inspect
        end 
        results << p
      end
    end
    results
  end
  
  def add_parents(user, attr)
    femail = attr.delete("femail")
    memail = attr.delete("memail")
    fname = attr.delete("fname")
    mname = attr.delete("mname")
    if(femail)
      father = create_user(femail, fname, Parent.new)        
      if father.invite_over_email(current_user)
        user.profile.add_friend(father.profile)
        @ok_parents[user] = father
      else
        @failed_parents[user] = father
      end
    end
    if(memail)
      mother = create_user(memail, mname, Parent.new)
      if mother.invite_over_email(current_user)
        user.profile.add_friend(mother.profile)
        @ok_parents[user] = father
      else
        @failed_parents[user] = mother
      end
    end    
  end
  
  def create_user(email, name, person)
    first = last = nil
    first, last = name.split(' ',2) if name
    email = email.strip if email
    user = User.new(:email => email)
    user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
    user.profile = Profile.new(:first_name => first,:last_name => last)
    user.person = person
    return user
  end
end
