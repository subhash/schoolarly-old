class Member::KlassesController < Member::GroupsController
  def find_group
    @group = Klass.find(params[:id]).group if params[:id]
  end
  
  def new
    @parent = School.find(params[:school_id]).group
    @group = Group.new(:parent => @parent)
  end
  
  
  def create
    @group = Group.new(params[:group])
    @group.author = current_user
    @group.moderated = true
    @group.private = false
    @group.network = Klass.new
    @group.save  
    if @group.errors.empty?     
      @group.join(current_user, true)
      @group.activate!
      flash[:ok] = I18n.t("klasses.member.created", :klass_name => @group.name, :school_name => @group.parent.name)
      redirect_to member_klass_path(@group.network)
    else
      render :action => 'new'
    end    
  end
  
  
  
end