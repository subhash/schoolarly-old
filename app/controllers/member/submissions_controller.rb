class Member::SubmissionsController < Member::BaseController
  
  uses_tiny_mce :only => [:new, :create, :edit, :update]
  before_filter :find_assignment
  
  def new
    @user ||= current_user  
    @submission = Submission.new(:post => Post.new, :assignment => @assignment)
  end
  
  def create
    @user ||= current_user 
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
  
  private
  def find_assignment
    @assignment  = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
end
