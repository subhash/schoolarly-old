# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
    
  helper_method :path_for_group
  
  def path_for_group(group)
    case group.network_type
      when 'School'
      school_path(group.network)
      when  'Klass'
      member_klass_path(group.network)
    else
      group_path(group) 
    end    
  end
  
end
