class Member::QuizzesController < Member::BaseController
  before_filter :find_group
  
  def create
    @quiz = Quiz.new(:user => current_user)
    @quiz.content = params[:quiz]
    if @quiz.save
      if request.xhr?
        render :json => {:location => @group ? member_group_path(@group) : member_dashboard_path}
      end
    end
  end
  

  def set_javascripts_and_stylesheets
    @javascripts = %w(application)
    @stylesheets = %w()
    @feeds = %w()
  end

  private

  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end


end