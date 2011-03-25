class Member::SubmissionsController < Member::BaseController
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  before_filter :find_assignment, :only => [:new, :create]
  before_filter :find_submission, :except => [:new, :create]
  before_filter :find_user
  
  def new
    @submission = Submission.new(:post => Post.new, :assignment => @assignment)
  end
  
  def create
    @submission = Submission.create(params[:submission])
    @submission.post.user = @user  
    respond_to do |wants|
      if @submission.save 
        @submission.post.publish!  if params[:publish]
        wants.html do
          flash[:ok] = I18n.t('submissions.site.new.success')
          redirect_back_or_default member_assignment_path(@assignment)
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
    puts @submission.post.body
  end
  
  def update
    respond_to do |wants|
      if @submission.update_attributes(params[:submission]) 
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
  
  private
  def find_assignment
    @assignment  = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
  
  def find_submission
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
  end
  
  def find_user
    @user = User.find(params[:user]) if params[:user]
    @user ||= current_user
  end
  
end
