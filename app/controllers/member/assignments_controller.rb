class Member::AssignmentsController < Member::BaseController
  
  before_filter :find_group
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  
  def new
    @assignment = Assignment.new
  end
  
  def create
    @assignment = Assignment.new(params[:assignment])
    @assignment.post.user = current_user
    published_at = @assignment.post.published_at
    @assignment.post.publish!
    @assignment.post.published_at = published_at if published_at > Time.now
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
  
  
  def show
    @assignment =  Assignment.find(params[:id])
    @post = @assignment.post
    @shared_groups = @assignment.shares_to_groups.collect(&:shared_to)
  end
  
  
  private  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
