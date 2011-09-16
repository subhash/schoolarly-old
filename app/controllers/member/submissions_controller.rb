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
    respond_to do |wants|
      if @submission.save 
        if params[:publish]
          @submission.post.publish!          
          @submission.share_to(@assignment.user, @submission.submitter) 
          @submission.share_to(@submission.user, @submission.submitter) unless @submission.user == @submission.submitter
          @submission.post.to_crocodoc!(true)
          wants.html do
            flash[:ok] = I18n.t('submissions.site.new.success')
            redirect_to member_submission_path(@submission)
          end
        else
          wants.html do
            flash[:ok] = I18n.t('submissions.site.new.saved')
            redirect_to edit_member_submission_path(@submission)
          end
        end   
      else
        wants.html do
          flash[:error] = I18n.t('submissions.site.new.failure')
          render :new
        end
      end      
    end
  end
  
  def destroy
    respond_to do |wants|
      wants.html do
        if @submission.destroy
          flash[:ok] = I18n.t('submissions.member.remove.success')
          redirect_to member_assignment_path(@assignment)
        else                              
          flash[:error] = I18n.t('submissions.member.remove.failure')
          render :show
        end  
      end
    end
  end
  
  def sendback
    unless @submission.user == current_user
      @submission.share_to(@submission.user,current_user)  
      @message = Message.new(
      :from => @assignment.user,
      :to => @submission.user,
      :subject => I18n.t('submissions.member.return.subject'),
      :content => @template.link_to("here", I18n.t('submissions.member.return.content', :url => member_submission_url(@submission)))
      )   
      begin
        @message.dispatch!
      rescue Exception => e
        error = e
        break
      end
    end
    respond_to{|wants|
      wants.html do
        flash[:ok] = I18n.t('submissions.member.return.success')
        redirect_to member_submission_path(@submission)
      end  
    }
  end
  
  def edit
  end
  
  def update
    @submission.attributes = params[:submission]
    respond_to do |wants|
      if @submission.save
        if @submission.returned_to?(current_user)
          @submission.post.draft! unless @submission.post.state == 'draft'
          @submission.post.published_at = nil
          @submission.post.save!
          @submission.shares.each {|s| s.destroy }
        end
        if params[:publish]
          @submission.post.publish!       
          @submission.share_to(@assignment.user, @submission.submitter)
          @submission.share_to(@submission.user, @submission.submitter) unless @submission.user == @submission.submitter
          @submission.post.to_crocodoc!(true)
          wants.html do
            flash[:ok] = I18n.t('submissions.site.edit.success')
            redirect_to member_submission_path(@submission)
          end
        else
          wants.html do
            flash[:ok] = I18n.t('submissions.site.new.saved')
            redirect_to edit_member_submission_path(@submission)
          end
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
  end
  
  private
  def find_assignment
    @assignment  = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
  
  def find_submission
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
    @post = @submission.post
    raise UnauthorizedException.new unless i_own?(@submission) or shared_to_me?(@submission)
  end
  
  def find_user
    @user = User.find(params[:user]) if params[:user]
    @user ||= current_user
    @profile = @user.profile
  end
  
end
