class Member::QuizzesController < Member::BaseController
  before_filter :find_group
  
  def add_new
    @quiz = Quiz.new(:user => current_user)
    @quiz.title = params[:title]
    @quiz.instruction = params[:instruction]
    @quiz.content = params[:quiz]
    if @quiz.save
      @group.share(current_user, @quiz.class.to_s, @quiz.id) if @group      
      respond_to do |wants|
        wants.js {render :json => {"location" => @group ? member_group_path(@group) : member_dashboard_path}}
      end
    end
  end
  
  def show
    @quiz = Quiz.find(params[:id]) if params[:id]
  end
  

  def set_javascripts_and_stylesheets
    @javascripts = %w(application)
    @stylesheets = %w()
    @feeds = %w()
  end

  private

  def find_group
    @group = Group.find(params[:group_id]) if params[:group_id]
  end


end