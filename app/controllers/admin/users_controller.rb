class Admin::UsersController < Admin::BaseController
  
  def hijack
    self.current_user = @user
    redirect_to member_dashboard_path
  end
  
end
