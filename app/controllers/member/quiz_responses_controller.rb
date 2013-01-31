class Member::QuizResponsesController < Member::BaseController
  before_filter :find_quiz
  
  def create
    
    @quiz_response = QuizResponse.new(:user => current_user, :quiz => @quiz)
    @quiz_response.content = params[:quiz_response]
    if @quiz_response.save
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

  def find_quiz
    puts "quiz_id = #{params[:quiz_id]}"
    @quiz = Quiz.find(params[:quiz_id]) if params[:quiz_id]
    puts "@quiz - #{@quiz}"
  end


end
