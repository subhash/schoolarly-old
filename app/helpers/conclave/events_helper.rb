module Conclave
  module EventsHelper
    
    def i_am_the_owner_of?(event)
      event.owner == current_user
    end
    
    def write_event_date_time(event, format=:short)
      if (event.start_date != event.end_date)
        write_event_date(event)
      else
        write_event_time(event)
      end
      
    end
    
    def write_event_date_time_detail(event, format=:short)
      if (event.start_date != event.end_date)
        "#{I18n.t('tog_conclave.site.from_date')}: #{event.starting_date(format)}, #{event.starting_time} #{I18n.t('tog_conclave.site.to_date')}: #{event.ending_date(format)}, #{event.ending_time}"
      else
        write_event_time(event)
      end
      
    end
    
  end
end
