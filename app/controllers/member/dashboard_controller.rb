class Member::DashboardController < Member::BaseController

  def index
    @profile = current_user.profile   
  end

end