class Member::AssignmentsController < Member::BaseController
  
  before_filter :find_group
  before_filter :default_rubrics, :except => [:publish_grades]
  before_filter :find_assignment, :except => [:new, :create]
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  
  
  def new
    @assignment = Assignment.new(:post => Post.new(:published_at => Time.now)) 
  end 
  
  def create
    @assignment = Assignment.new(params[:assignment])
    @assignment.post.user = current_user
    published_at = Time.now || @assignment.post.published_at
    @assignment.post.publish!
    @assignment.post.published_at = published_at if published_at > Time.now
    @assignment.rubric = Rubric.find(params[:rubric]) if params[:rubric]
    respond_to do |wants|
      if @assignment.save
        @group.share(current_user, @assignment.class.to_s, @assignment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('assignments.member.add_success')
          redirect_back_or_default member_assignment_path(@assignment)
        end
      else
        @rubric = @assignment.rubric                                
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
    @publish = @assignment.grades.select{|g|!g.shared_to?(g.user, @assignment.user)}.any?
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
        wants.html do
          flash[:ok] = I18n.t('assignments.member.edit.success')
          redirect_back_or_default member_assignments_path(@assignment)
        end
      else
        wants.html do
          flash[:error] = I18n.t('assignments.member.edit.failure')
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
  
  
  def publish_grades
    for grade in @assignment.grades
      grade.share_to(grade.user, @assignment.user)
    end
    puts "after publish"
    flash[:ok] = I18n.t('assignments.member.grades.publish_success')
    redirect_to :action => :show
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
