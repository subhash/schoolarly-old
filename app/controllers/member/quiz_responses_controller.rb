class Member::QuizResponsesController < Member::BaseController
  before_filter :find_quiz
  
  def add_new
    @quiz_response = QuizResponse.new(:user => current_user, :quiz => @quiz)
    @quiz_response.content = params[:quiz_response]
    if @quiz_response.save
      if request.xhr?
        render :json => {:location => member_quiz_response_path(@quiz_response)}
      end
    end
  end
  
  def show
    @quiz_response = QuizResponse.find(params[:id]) if params[:id]
    @quiz = @quiz_response.quiz
  end  
  

  def set_javascripts_and_stylesheets
    @javascripts = %w(application)
    @stylesheets = %w()
    @feeds = %w()
  end

  private

  def find_quiz
    @quiz = Quiz.find(params[:quiz_id]) if params[:quiz_id]
  end


end
