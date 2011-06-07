class Member::HomeActivitiesController < Member::AssignmentsController
  
  def new
    super
    @home_activity = HomeActivity.new(:assignment => @assignment,:due_date => 1.day.from_now)
  end
  
  
  def create
    @home_activity = HomeActivity.new(params[:home_activity])
    @home_activity.assignment.post.user = current_user
    published_at = @home_activity.assignment.post.published_at
    @home_activity.assignment.post.publish!
    @home_activity.assignment.post.published_at = published_at if published_at > Time.now
    @home_activity.assignment.rubric = Rubric.find(params[:rubric]) if params[:rubric]
    respond_to do |wants|
      if @home_activity.save
        @group.share(current_user, @home_activity.assignment.class.to_s, @home_activity.assignment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('assignments.member.add_success')
          redirect_back_or_default member_home_activities_path(@home_activity)
        end
      else
        @rubric = @home_activity.assignment.rubric                                
        wants.html do
          flash[:error] = I18n.t('assignments.member.add_failure')
          render :new
        end
      end      
    end
  end
  
end
