module Conclave
  module EventsHelper
    
    def i_am_the_owner_of?(event)
      event.owner == current_user
    end
    
  end
end
