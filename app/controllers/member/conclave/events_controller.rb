class Member::Conclave::EventsController < Member::BaseController
  
    helper LaterDude::CalendarHelper
  
  def create
    @group = Group.find(params[:group]) if params[:group]
    @event = Event.new(params[:event])
    @event.owner = current_user
    @event.save!
    flash[:ok] = I18n.t("tog_conclave.member.event_created", :title => @event.title)
    if @group
      @group.share(current_user, @event.class.to_s, @event.id)
      redirect_back_or_default member_groups_path(@group)
    else            
      redirect_to(member_conclave_events_path)           
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = I18n.t("tog_conclave.member.error")
    render :action => 'new'
  end
  
end