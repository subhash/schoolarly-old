class Member::AssignmentsController < Member::BaseController
  
  before_filter :find_group
  before_filter :find_assignment, :except => [:new, :create]
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  
  def new
    @assignment = Assignment.new
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
  end
  
  def create
    @assignment = Assignment.new(params[:assignment])
    @assignment.post.user = current_user
    published_at = @assignment.post.published_at
    @assignment.post.publish!
    @assignment.post.published_at = published_at if published_at > Time.now
    @assignment.rubric = Rubric.find(params[:rubric]) if params[:rubric]
    respond_to do |wants|
      if @assignment.save
        @group.share(current_user, @assignment.class.to_s, @assignment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('assignments.member.add_success')
          redirect_back_or_default member_assignments_path(@assignment)
        end
      else
        @rubric = @assignment.rubric
        @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"                                 
        wants.html do
          flash[:error] = I18n.t('assignments.member.add_failure')
          render :new
        end
      end      
    end
  end
  
  
  def show
    store_location    
    @shared_groups = @assignment.shares_to_groups.collect(&:shared_to)
    @submitters = @shared_groups.collect(&:student_users).flatten
  end
  
  def edit    
  end
  
  def update
    @assignment.attributes = params[:assignment]
    published_at = @assignment.post.published_at
    @assignment.post.published_at = published_at if published_at > Time.now
    respond_to do |wants|
      if @assignment.save
        @group.share(current_user, @assignment.class.to_s, @assignment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('assignments.member.edit_success')
          redirect_back_or_default member_assignments_path(@assignment)
        end
      else
        wants.html do
          flash[:error] = I18n.t('assignments.member.edit_failure')
          render :new
        end
      end      
    end  
  end
  
  
  private  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
  def find_assignment
    @assignment =  Assignment.find(params[:id])
    @post = @assignment.post
    @rubric = @assignment.rubric
  end
  
end
