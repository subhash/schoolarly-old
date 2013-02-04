module Member::QuizzesHelper
  
  def my_quiz_path(quiz)
    if i_am_the_author_of?(quiz)
      member_quiz_path(quiz)
    else
      quiz_response = quiz.quiz_responses.by(current_user)
      quiz_response ? member_quiz_response_path(quiz_response) : new_member_quiz_quiz_response_path(quiz)
    end
  end
  
end
