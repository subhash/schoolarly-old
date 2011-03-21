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
  
  
  def index
    puts 'request accepts - '+request.headers["Accept"].inspect
    @order = params[:order] || 'title'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'asc'
    @events = current_user.events.paginate :per_page => 10,
                                           :page => @page,
                                           :order => @order + " " + @asc
    respond_to do |wants|
      wants.html
      wants.json {
        from = Time.at(params[:start].to_i)
        to = Time.at(params[:end].to_i)
        @events = current_user.events.between(from.to_date, to.to_date)
        events = @events.collect do |event|
          start_time = event.start_date.to_time.advance(:hours => event.start_time.hour, :minutes => event.start_time.min, :seconds => event.start_time.sec)
          {:title => event.title, :start => start_time.iso8601}          
        end
        render :text => events.to_json
        puts "start #{from} to stop #{to}"
        puts 'json - '+events.to_json
      }
    end
  end
  
end