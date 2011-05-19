class StaticController < ApplicationController
  
  def dumbledore
    self.current_user = User.find_by_email('dumbledore@schoolarly.com')
    redirect_to member_dashboard_path
  end
  
  def harry
    self.current_user = User.find_by_email('harry@schoolarly.com')
    redirect_to member_dashboard_path
  end
  
  def hermione
    self.current_user = User.find_by_email('hermione@schoolarly.com')
    redirect_to member_dashboard_path
  end
  
  def mcgonagall
    self.current_user = User.find_by_email('mcgonagall@schoolarly.com')
    redirect_to member_dashboard_path
  end
  
  def hooch
    self.current_user = User.find_by_email('hooch@schoolarly.com')
    redirect_to member_dashboard_path
  end
  
end