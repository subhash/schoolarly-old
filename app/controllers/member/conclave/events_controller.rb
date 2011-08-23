include IceCube

class Member::Conclave::EventsController < Member::BaseController
  
  helper LaterDude::CalendarHelper
  
  before_filter :find_group
  
  def new
    params[:event] ||= {:url => "http://"}
    @event = Event.new(params[:event])
    if(params[:start])
      start_time = Time.zone.parse(params[:start])
      @event.start_date = start_time.to_date
      @event.start_time = start_time.to_time
    end
    if(params[:end])
      end_time = Time.zone.parse(params[:end])
      @event.end_date = end_time.to_date
      @event.end_time = end_time.to_time
    end
    @event.capacity ||= 0
    @event.start_date ||= Date.today
    @event.start_time ||= 1.hour.from_now
    @event.end_date ||= Date.today
    @event.end_time ||= 2.hour.from_now
  end
  
  def create
    @event = Event.new(params[:event])
    @event.owner = current_user
    @event.save!
    flash[:ok] = I18n.t("tog_conclave.member.event_created", :title => @event.title)
    if @group
      @group.share(current_user, @event.class.to_s, @event.id)
      redirect_back_or_default member_group_path(@group)
    else            
      redirect_to(member_conclave_events_path)           
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = I18n.t("tog_conclave.member.error")
    render :action => 'new'
  end
  
  
  def index
    store_location
    respond_to do |wants|
      wants.html do
        @order = params[:order] || 'start_date'
        @page = params[:page] || '1'
        @asc = params[:asc] || 'title'
        if @group
          groups = [@group]
        else
          groups = current_user.groups
        end
        @events = Share.shared_to_groups_of_type(groups,'Event').collect(&:shareable).paginate :per_page => 5,
                                               :page => @page,
                                               :order => @order + " " + @asc 
        @assignments = Share.shared_to_groups_of_type(groups, 'Assignment').collect(&:shareable).delete_if{|a| !a.date and !a.due_date}.paginate :per_page => 5,
                                               :page => @page,
                                               :order => @order + " " + @asc                                                
      end
      wants.json do
        from = Time.at(params[:start].to_i)
        to = Time.at(params[:end].to_i)
        @events = between(from, to, 'Event')
        events = []
        @events.each do |event|
          start_offset = {:hours => event.start_time.hour, :minutes => event.start_time.min, :seconds => event.start_time.sec}
          end_offset = {:hours => event.end_time.hour, :minutes => event.end_time.min, :seconds => event.end_time.sec}
          start_time = event.start_date.to_time.advance(start_offset)
          end_time = event.end_date.to_time.advance(end_offset)
          duration = end_time - start_time
          if event.recurrence.blank? || event.recurrence == 'once'
            events << {:id => event.id, :title => event.title, :start => start_time.iso8601, :end => end_time.iso8601}
          else
            schedule = Schedule.new(start_time)
            recurrence = Rule.send(event.recurrence)
            recurrence.until(event.until)
            schedule.add_recurrence_rule(recurrence)
            schedule.all_occurrences.each do |occurrence|
              events << {:id => event.id, :title => event.title, :start => occurrence.iso8601, :end => (occurrence + duration).iso8601, :color => 'red'}
            end
          end
        end
        @assignments = between(from, to, 'Assignment').delete_if{|a| !a.date and !a.due_date}
        events += @assignments.collect do |ass|
          if ass.date
            start_time = ass.date.to_time.advance(:hours => ass.start_time.hour, :minutes => ass.start_time.min, :seconds => ass.start_time.sec)
            end_time = ass.date.to_time.advance(:hours => ass.end_time.hour, :minutes => ass.end_time.min, :seconds => ass.end_time.sec)
          else
            start_time = ass.due_date
            end_time = ass.due_date
          end
          {:title => ass.name, :start => start_time.iso8601, :end => end_time.iso8601}          
        end
        render :text => events.to_json
      end
    end
  end
  
  private
  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
  def between(from, to, type)
    # TODO need to check from and to
    if @group
      groups = [@group]
    else
      groups = current_user.groups   
    end
    # TODO check why we needed (current_user.events  | 
    Share.shared_to_groups_of_type(groups, type).collect(&:shareable)
  end
  
  def find_event
    @event = Event.find(params[:id]) rescue nil
    if @event.nil?
      flash[:error] = I18n.t("tog_conclave.page_not_found")
      redirect_to member_conclave_events_path
    end
  end
  
  def set_javascripts_and_stylesheets
    @javascripts = %w(application)
    @stylesheets = %w()
    @feeds = %w()
  end 
  
end