class Member::AssignmentsController < Member::BaseController
  
  before_filter :find_group
  
  def new
    @assignment = Assignment.new
  end
  
  def create
    @assignment = Assignment.new(params[:assignment])
    @assignment.user = current_user
    respond_to do |wants|
      if @assignment.save
        @group.share(current_user, @assignment.class.to_s, @assignment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('assignments.member.add_success')
          redirect_back_or_default member_assignments_path(@assignment)
        end
      else
        wants.html do
          flash[:error] = I18n.t('assignments.member.add_failure')
          render :new
        end
      end      
    end
  end
  
    
#  def show
#    @session_id = Assignment.find(params[:id]).from_crocodoc(current_user.profile.full_name)
#  end
  
  
  private  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
