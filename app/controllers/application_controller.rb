# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class UnauthorizedException < StandardError
end

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  #  rescue_from UnauthorizedException, :with => :unauthorized
  
  include Smerf
  
  helper_method :i_own?, :shared_to_me?
  
  def smerf_user_id
    session[:smerf_user_id] || current_user.id      
  end
  
  def i_own?(object)
    case(object.class.name) 
      when 'Event', 'Post', 'Picto::Photo'
      object.owner == current_user
      when 'Assignment'
      object.post.owner == current_user
      when 'Submission'
       (object.post.owner == current_user) || (object.user == current_user)
    else
      object.user == current_user
    end
    
  end
  
  def shared_to_me?(object)
    object.shares.any? do |share| 
      s = share.shared_to
       (s == current_user) || (current_user.friend_users.include? s) || (current_user.groups.include? s) 
    end
  end
  
  private
  
  def unauthorized
    render :template => "member/site/unauthorized"
  end
  
  def ban_access
    raise UnauthorizedException.new
  end
  
end
