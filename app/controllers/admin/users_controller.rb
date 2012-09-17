class Admin::UsersController < Admin::BaseController
  
  def hijack
    self.current_user = @user
    redirect_to member_dashboard_path
  end
  
  
  def show
    @user = User.find(params[:id])
    @profile = @user.profile
  end
  
  
    def index
      @users = User.find(:all, :include => :profile)
    end
end
