# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class UnauthorizedException < StandardError
end

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :set_title
  
  rescue_from UnauthorizedException, :with => :unauthorized
  
  include Smerf
  
  def smerf_user_id
    session[:smerf_user_id] || current_user.id      
  end
  
  private
  
  def set_title
    @title = current_user.school.group.name if current_user
  end
  
  def unauthorized
    render :template => "member/site/unauthorized"
  end
  
  def ban_access
    raise UnauthorizedException.new
  end
  
end
