class Member::ClassActivitiesController < Member::AssignmentsController
  
  def new
    super
    @class_activity = ClassActivity.new(:assignment => @assignment,:date => Date.tomorrow, :start_time => Time.now, :end_time => 1.hour.from_now)
  end
  
  
  def create
    @class_activity = ClassActivity.new(params[:class_activity])
    @class_activity.assignment.post.publish!
    respond_to do |wants|
      if @class_activity.save
        @group.share(current_user, @class_activity.assignment.class.to_s, @class_activity.assignment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('assignments.member.add_success')
          redirect_back_or_default member_class_activities_path(@class_activity)
        end
      else
        @rubric = @class_activity.assignment.rubric                                
        wants.html do
          flash[:error] = I18n.t('assignments.member.add_failure')
          render :new
        end
      end      
    end
  end
  
end
