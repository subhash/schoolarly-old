class Member::Conclave::EventsController < Member::BaseController
  
  helper LaterDude::CalendarHelper
  
  before_filter :find_group
  
  def new
    @event = Event.new(:url => "http://")
    @event.capacity = 0
    @event.start_date = Date.today
    @event.start_time = Time.now
    @event.end_date = Date.today
    @event.end_time = 1.hour.from_now
  end
  
  def create
    @event = Event.new(params[:event])
    #    puts "validation = "+ !(@event.start_date && @event.end_date && @event.start_time && @event.end_time) || (@event.start_date > @event.end_date || (@event.start_date == @event.end_date && @event.start_time >= @event.end_time))
    puts "event = "+@event.inspect
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
    respond_to do |wants|
      wants.html do
        @order = params[:order] || 'start_date'
        @page = params[:page] || '1'
        @asc = params[:asc] || 'desc'
        if @group
          @events = @group.sharings.of_type('Event').map(&:shareable).paginate :per_page => 3,
                                               :page => @page,
                                               :order => @order + " " + @asc
        else
          @events = (current_user.events  | Share.shared_to_groups_of_type(current_user.groups,'Event').collect(&:shareable)).paginate :per_page => 3,
                                               :page => @page,
                                               :order => @order + " " + @asc
        end                                       
      end
      wants.json do
        from = Time.at(params[:start].to_i)
        to = Time.at(params[:end].to_i)
        @events = between(from, to)
        puts "group #{@group} events #{@events.inspect}"
        events = @events.collect do |event|
          start_time = event.start_date.to_time.advance(:hours => event.start_time.hour, :minutes => event.start_time.min, :seconds => event.start_time.sec)
          {:title => event.title, :start => start_time.iso8601}          
        end
        render :text => events.to_json
        puts "start #{from} to stop #{to}"
        puts 'json - '+events.to_json
      end
    end
  end
  
  private
  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
  def between(from, to)
    if @group
      @group.sharings.of_type('Event').map(&:shareable)
    else
      # TODO .between(from.to_date, to.to_date)
       (current_user.events  | Share.shared_to_groups_of_type(current_user.groups,'Event').collect(&:shareable))
    end    
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