class Member::AssignmentsController < Member::BaseController
  
  before_filter :find_group
  before_filter :default_rubrics
  before_filter :find_assignment, :except => [:new, :create]
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  
  def new
    @assignment = Assignment.new(:post => Post.new(:published_at => Time.now)) 
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
    @assignment.rubric = Rubric.find(params[:rubric]) if params[:rubric]    
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
  
  
  def set_javascripts_and_stylesheets
    @javascripts = %w(application)
    @stylesheets = %w()
    @feeds = %w()
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
  
  def default_rubrics
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric').collect(&:shareable)).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC" 
  end
  
end
