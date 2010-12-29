class Member::SchoolsController < Member::GroupsController
  
  def create
    @group = Group.new(params[:group])
    @group.author = current_user
    @group.moderated = true
    @group.private = false
    @group.network = School.new
    @group.save
    
    
    if @group.errors.empty?
      
      @group.join(current_user, true)
      #    @group.activate_membership(current_user)
      
      if current_user.admin == true || Tog::Config['plugins.tog_social.group.moderation.creation'] != true
        @group.activate!
        flash[:ok] = I18n.t("tog_social.groups.member.created")
        redirect_to group_path(@group)
      else
        
        admins = User.find_all_by_admin(true)        
        admins.each do |admin|
          Message.new(
            :from => current_user,
            :to   => admin,
            :subject => I18n.t("schools.member.mail.activation_request.subject", :school_name => @group.name),
            :content => I18n.t("schools.member.mail.activation_request.content", 
                               :user_name   => current_user.profile.full_name, 
                               :school_name => @group.name, 
                               :activation_url => edit_admin_group_url(@group)) 
          ).dispatch!     
        end
        
        flash[:warning] = I18n.t("tog_social.groups.member.pending")
        redirect_to schools_path
      end
    else
      render :action => 'new'
    end
    
  end
  
  
  
end