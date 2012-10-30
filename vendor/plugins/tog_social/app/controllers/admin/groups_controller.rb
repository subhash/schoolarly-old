class Admin::GroupsController < Admin::BaseController
  
  def index
    @order = params[:order] || 'name'
    @page = params[:page] || '1'
    @groups = Group.paginate :per_page => 20,
                             :page => @page,
                             :order => "#{@order} ASC"
  end
  
  def edit
    @group = Group.find(params[:id])
  end
  
  def update
    @group = Group.find(params[:id])    
    @group.update_attributes!(params[:group])
    @group.save
    flash[:ok] =  I18n.t("tog_social.groups.admin.updated", :name => @group.name) 
    redirect_to edit_admin_group_path(@group)
  end  
  
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    respond_to do |wants|
      wants.html do
        flash[:ok]= I18n.t("tog_social.groups.admin.deleted")
        redirect_to admin_groups_path
      end
    end
  end
  
  def activate
    if @group.archived?
      new_name = @group.name.split("[Archived on")[0]
      @group.update_attributes!(:name => new_name)
      @group.reactivate!
    else
      @group.activate!
    end
    flash[:ok] =  I18n.t("tog_social.groups.admin.updated", :name => @group.name) 
    redirect_to member_group_path(@group)
  end
  
end