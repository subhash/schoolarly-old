class Member::SubmissionsController < Member::BaseController
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  before_filter :find_assignment, :only => [:new, :create]
  before_filter :find_submission, :except => [:new, :create]
  before_filter :find_user
  
  def new
    @submission = Submission.new(:post => Post.new, :assignment => @assignment, :user => @user)
  end
  
  def create
    @submission = Submission.new(params[:submission])
    @submission.post.user = current_user
    @submission.post.to_crocodoc(true)
    respond_to do |wants|
      if @submission.save 
        @submission.post.publish!  if params[:publish]
        wants.html do
          flash[:ok] = I18n.t('submissions.site.new.success')
          redirect_to member_submission_path(@submission)
        end
      else
        wants.html do
          flash[:error] = I18n.t('submissions.site.new.failure')
          render :new
        end
      end      
    end
  end
  
  def edit
  end
  
  def update
    @submission.attributes = params[:submission]
    @submission.post.to_crocodoc(true)
    respond_to do |wants|
      if @submission.save 
        @submission.post.publish!  if params[:publish]
        wants.html do
          flash[:ok] = I18n.t('submissions.site.edit.success')
          redirect_back_or_default member_assignment_path(@assignment)
        end
      else
        wants.html do
          flash[:error] = I18n.t('submissions.site.edit.failure')
          render :edit
        end
      end      
    end
  end
  
  def show
    @assignment = @submission.assignment
    @user = @submission.user
    @submitter = @submission.post.owner
    @profile = @user.profile
    if @submission.post.uuid
      @session = @submission.post.from_crocodoc(current_user.profile.full_name, @submission.assignment.post.user == current_user)
    end
    @grade = @assignment.grades.for_user(@user)
    puts '@grade - '+@grade.inspect
  end
  
  private
  def find_assignment
    @assignment  = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
  
  def find_submission
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
    @post = @submission.post
  end
  
  def find_user
    @user = User.find(params[:user]) if params[:user]
    @user ||= current_user
    @profile = @user.profile
  end
  
end
