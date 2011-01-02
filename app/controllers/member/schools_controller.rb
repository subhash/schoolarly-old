class Member::SchoolsController < Member::GroupsController
  
  def find_group
    @group = School.find(params[:id]).group if params[:id]
  end
  
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
        flash[:ok] = I18n.t("schools.member.group_created", :school_name => @group.name)
        redirect_to school_path(@group.network)
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
        
        flash[:warning] = I18n.t("schools.member.group_pending")
        redirect_to schools_path
      end
    else
      render :action => 'new'
    end
    
  end
  
  
  
end